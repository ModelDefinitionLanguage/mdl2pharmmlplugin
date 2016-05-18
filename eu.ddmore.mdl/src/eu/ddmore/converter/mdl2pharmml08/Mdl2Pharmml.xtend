package eu.ddmore.converter.mdl2pharmml08

import eu.ddmore.converter.treerewrite.MdlRootProvider
import eu.ddmore.converter.treerewrite.VectorAttributeRewrite
import eu.ddmore.mdl.mdl.ListDefinition
import eu.ddmore.mdl.mdl.Mcl
import eu.ddmore.mdl.mdl.MclObject
import eu.ddmore.mdl.provider.BlockDefinitionTable
import eu.ddmore.mdl.provider.ListDefinitionProvider
import eu.ddmore.mdl.utils.DomainObjectModelUtils
import eu.ddmore.mdl.utils.MdlUtils
import eu.ddmore.mdl.validation.MdlValidator
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.EcoreUtil2

import static eu.ddmore.converter.mdl2pharmml08.Constants.*

class Mdl2Pharmml {
	static val mdlVersion = "6.0"
	
	extension MdlUtils mu = new MdlUtils
	extension DomainObjectModelUtils domu = new DomainObjectModelUtils
	extension MdlRootProvider mrp = new MdlRootProvider
	extension ModelDefinitionPrinter mdp = new ModelDefinitionPrinter
	extension ModellingStepsPrinter msp = new ModellingStepsPrinter
	extension FunctionDefinitionPrinter fdp = new FunctionDefinitionPrinter
	extension ListDefinitionProvider ldp = new ListDefinitionProvider

	var Mcl mdlRoot

	private def copyMdl(Mcl orig){
		mdlRoot = EcoreUtil.copy(orig)
//		mdlRoot = orig
	}

	private def rewriteTree(){
		val vectArgR = new VectorAttributeRewrite
		var cntr = 0
		val iter = mdlRoot.eAllContents
		while(iter.hasNext){
			val node = iter.next
			if(vectArgR.doSwitch(node) != null) cntr++	
		}
//		val finalCount = cntr
	}
	
	def private boolean isDesignObjDefined(Mcl it){
		isObjDefinedInMog(MdlValidator::DESIGNOBJ)
	}
	
	def private boolean isObjDefinedInMog(Mcl it, String objTypeName){
		val mogObjBlk = mogObject.getBlocksByName(BlockDefinitionTable::MOG_OBJ_NAME)
		mogObjBlk.head.statementsFromBlock.exists[stmt|
			if(stmt instanceof ListDefinition){
				val objType = stmt.firstAttributeList.getAttributeEnumValue('type')
				objType == objTypeName
			}
			else false
		]
	}
	
	def private boolean isParamObjDefined(Mcl it){
		isObjDefinedInMog(MdlValidator::PARAMOBJ)
	}
	

  	def convertToPharmML(MclObject mog) {
  		copyMdl(EcoreUtil2.getContainerOfType(mog.eContainer, Mcl))
  		rewriteTree()
		val paramWriter = if(mdlRoot.isParamObjDefined){
			new StandardParameterWriter(mdlRoot.modelObject)
		}
		else{
			new PriorParameterWriter(mdlRoot.modelObject, mdlRoot.priorObj)
		}
		val TrialDesignObjectPrinter trialDesignWriter = if(mdlRoot.isDesignObjDefined)
									new TrialDesignDesignObjectPrinter(mdlRoot, paramWriter)
								else
									new TrialDesignDataObjectPrinter(mdlRoot, paramWriter)
		'''
			<?xml version="1.0" encoding="UTF-8"?>
			<PharmML 
				«printPharmMlNameSpaces»
				writtenVersion="«writtenVersion»">
				<ct:Name>"generated by MDL2PharmML v.«mdlVersion»"</ct:Name>
				<IndependentVariable symbId="«mdlRoot.mdlObj.mdlIdv?.name ?: "T"»"/>
				«mdlRoot.mdlObj.writeFunctionDefinitions»	
				«mdlRoot.mdlObj.writeModelDefinition(if(mdlRoot.isParamObjDefined) mdlRoot.paramObj	else mdlRoot.priorObj, paramWriter)»
				«trialDesignWriter.writeTrialDesign»
				«writeModellingSteps(mdlRoot.mdlObj, if(mdlRoot.isParamObjDefined) mdlRoot.paramObj else mdlRoot.priorObj,
					if(mdlRoot.isDesignObjDefined) mdlRoot.designObj else mdlRoot.dataObj, mdlRoot.taskObj)»
			</PharmML>
		'''			
	}

	//+ Print PharmML namespaces
	protected def printPharmMlNameSpaces()
		'''
		xmlns:xsi="«xsi»" 
		xmlns="«xmlns_pharmML»"
		xsi:schemaLocation="«xsi_schemaLocation»"
		xmlns:math="«xmlns_math»"
		xmlns:ct="«xmlns_ct»"
		xmlns:ds="«xmlns_ds»"
		xmlns:mdef="«xmlns_mdef»"
		xmlns:mstep="«xmlns_mstep»"
		xmlns:design="«xmlns_design»"
		'''
}