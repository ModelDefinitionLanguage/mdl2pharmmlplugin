package eu.ddmore.converter.mdl2pharmml08

import eu.ddmore.mdl.mdl.AttributeList
import eu.ddmore.mdl.mdl.BlockStatement
import eu.ddmore.mdl.mdl.EquationDefinition
import eu.ddmore.mdl.mdl.ListDefinition
import eu.ddmore.mdl.mdl.Mcl
import eu.ddmore.mdl.mdl.MclObject
import eu.ddmore.mdl.mdl.SymbolReference
import eu.ddmore.mdl.provider.BlockDefinitionTable
import eu.ddmore.mdl.provider.ListDefinitionProvider
import eu.ddmore.mdl.utils.BlockUtils
import eu.ddmore.mdl.utils.DomainObjectModelUtils
import eu.ddmore.mdl.utils.ExpressionUtils
import eu.ddmore.mdl.utils.MdlUtils
import org.eclipse.xtext.EcoreUtil2

import static eu.ddmore.converter.mdl2pharmml08.Constants.*
import eu.ddmore.mdl.mdl.SubListExpression
import eu.ddmore.mdl.provider.SublistDefinitionProvider
import eu.ddmore.mdl.mdl.PropertyStatement
import eu.ddmore.mdl.mdl.ValuePair
import eu.ddmore.mdllib.mdllib.Expression

class TrialDesignDesignObjectPrinter implements TrialDesignObjectPrinter {
	extension MdlUtils mu = new MdlUtils 
	extension PharmMLExpressionBuilder peb = new PharmMLExpressionBuilder 
	extension ListDefinitionProvider ldp = new ListDefinitionProvider
	extension SublistDefinitionProvider sldp = new SublistDefinitionProvider
	extension BlockUtils bu = new BlockUtils
	extension DomainObjectModelUtils dom = new DomainObjectModelUtils
//	extension ConstantEvaluation ce = new ConstantEvaluation
//	extension TypeSystemProvider tsp = new TypeSystemProvider
//	extension MdlLibUtils mlu = new MdlLibUtils
//	extension LibraryUtils lib = new LibraryUtils
	extension ExpressionUtils eu = new ExpressionUtils

	val public static INTVN_TYPE_ATT_NAME = 'type'
	val public static INTVN_TYPE_BOLUS_VALUE = 'bolus'
	val public static INTVN_TYPE_INFUSION_VALUE = 'infusion'
	val public static SSINTERVAL_ATT_NAME = 'ssInterval'
	val public static SSEND_ATT_NAME = 'ssEnd'
	val public static INPUT_ATT_NAME = 'input'
	val public static AMT_ATT_NAME = 'amount'
	val public static DOSE_TIME_ATT_NAME = 'doseTime'
	val public static RATE_ATT_NAME = 'rate'
	val public static DURATION_ATT_NAME = 'duration'
	val public static SCALE_ATT_NAME = 'p'
	val public static INTVN_TYPE_COMBI_VALUE = 'combi'
	val public static COMBINATION_ATT_NAME = 'combination'
	val public static START_ATT_NAME = 'start'	
	val public static END_ATT_NAME = 'end'
	val public static INTVN_TYPE_RESET_ALL_VALUE = 'resetAll'	
	val public static INTVN_TYPE_RESET_VALUE = 'reset'	
	val public static RESET_VALUE_ATT = 'value'	
	val public static RESET_TIME_ATT = 'resetTime'	
	val public static RESET_VARIABLE = 'variable'
	val public static RESET_ATT = 'reset'
	val public static ARM_SIZE_ATT = 'armSize'
	val public static INTSEQ_ATT = 'interventionSequence'
	val public static INTSEQ_ADMIN_ATT = 'admin'
	val public static SAMPSEQ_ATT = 'samplingSequence'
	val public static SAMPSEQ_SAMP_ATT = 'sample'
	val public static TOTAL_SIZE_PROP = 'totalSize'
	val public static NUM_SAMPLES_PROP = 'numSamples'
	val public static NUM_ARMS_PROP = 'numArms'
	val public static SAME_TIMES_PROP = 'sameTimes'
	val public static TOTAL_COST_PROP = 'totalCost'



	val MclObject mObj
	val MclObject designObj

	new(Mcl mdl){
		this.mObj = mdl.modelObject
		this.designObj = mdl.designObject
	}




	override writeTrialDesign()'''
		<TrialDesign xmlns="«xmlns_design»">
			«IF mObj != null && designObj != null»
				«designObj.getBlocksByName(BlockDefinitionTable::DES_DESIGN_PARAMS).forEach[writeDesignParameters]»
				«designObj.getBlocksByName(BlockDefinitionTable::DES_INTERVENTION_BLK).forEach[writeInterventions]»
			«ENDIF»
		</TrialDesign>
	'''	

	def writeDesignParameters(BlockStatement designParamsBlk)'''
		«FOR e :designParamsBlk.statements»
			«IF e instanceof EquationDefinition»
				«e.writeDesignParameter»
			«ENDIF»
		«ENDFOR»
	'''

	def private writeDesignParameter(EquationDefinition ed)'''
		<mdef:DesignParameter symbId="«ed.name»">
			«IF ed.expression != null»
				«ed.expression.expressionAsAssignment»
			«ENDIF»
		</mdef:DesignParameter>
	'''
	
	def writeInterventions(BlockStatement designParamsBlk)'''
		<Interventions>
			«FOR stmt : designParamsBlk.statements»
				«IF stmt instanceof ListDefinition»
					«switch(stmt.firstAttributeList.getAttributeEnumValue(INTVN_TYPE_ATT_NAME)){
						case(INTVN_TYPE_BOLUS_VALUE):
							stmt.writeBolusDosing
						case(INTVN_TYPE_INFUSION_VALUE):
							stmt.writeInfusionDosing
						case(INTVN_TYPE_COMBI_VALUE):
							stmt.writeInterventionCombination
						case(INTVN_TYPE_RESET_ALL_VALUE):
							stmt.writeResetAll
						case(INTVN_TYPE_RESET_VALUE):
							stmt.writeReset
					}»
				«ENDIF»
			«ENDFOR»
		</Interventions>
	'''
	
	def private getModelVar(SubListExpression it, String attName){
		val targetVar = getAttributeExpression(attName)
		if(targetVar instanceof SymbolReference){
			mObj.findMdlSymbolDefn(targetVar.ref.name)
		}
		else null
	}
	
	def writeTargetMapping(AttributeList it){
		val targetVar = getAttributeExpression(INPUT_ATT_NAME)
		if(targetVar instanceof SymbolReference){
			val mdlTgtVar = mObj.findMdlSymbolDefn(targetVar.ref.name)
			val mdlVarBlk = EcoreUtil2.getContainerOfType(mdlTgtVar, BlockStatement)
			'''
				<TargetMapping blkIdRef="sm">
					«IF mdlVarBlk.blkId.name == BlockDefinitionTable::MDL_CMT_BLK»
						<ds:Map admNumber="«PKMacrosPrinter::INSTANCE.getCompartmentNum(mdlTgtVar)»"/>
					«ELSE»
						<ds:Map modelSymbol="«mdlTgtVar.name»"/>
					«ENDIF»
				</TargetMapping>
			'''
		}
		else{
			'''Error!'''
		}
	}
	
	def writeCommonDosing(AttributeList it)'''
			«IF hasAttribute(AMT_ATT_NAME)»
				<DoseAmount>
					«writeTargetMapping»
					«IF hasAttribute(SCALE_ATT_NAME)»
						<ct:Assign>
							<math:Binop op="times">
								«getAttributeExpression(AMT_ATT_NAME).pharmMLExpr»
								«getAttributeExpression(SCALE_ATT_NAME).pharmMLExpr»
							</math:Binop>
						</ct:Assign>
					«ELSE»
						«getAttributeExpression(AMT_ATT_NAME).expressionAsAssignment»
					«ENDIF»
				</DoseAmount>
			«ENDIF»
			«IF hasAttribute(SSEND_ATT_NAME)»
				<SteadyState>
					«IF hasAttribute(SSEND_ATT_NAME)»
						<EndTime>
							«getAttributeExpression(SSEND_ATT_NAME).expressionAsAssignment»
						</EndTime>
					«ENDIF»
					«IF hasAttribute(SSINTERVAL_ATT_NAME)»
						<Interval>
							«getAttributeExpression(SSINTERVAL_ATT_NAME).expressionAsAssignment»
						</Interval>
					«ENDIF»
				</SteadyState>
			«ENDIF»
			«IF hasAttribute(DOSE_TIME_ATT_NAME)»
				<DosingTimes>
					«getAttributeExpression(DOSE_TIME_ATT_NAME).expressionAsAssignment»
				</DosingTimes>
			«ENDIF»	'''
	
	
	def writeBolusDosing(ListDefinition ld){
		ld.writeAdministration[
		'''
		<Bolus>
			«writeCommonDosing»
		</Bolus>
		'''
		]
	}
	
	def writeInfusionDosing(ListDefinition ld){
		ld.writeAdministration[
		'''
		<Infusion>
			«writeCommonDosing»
			«IF hasAttribute(RATE_ATT_NAME)»
				<Rate>
					«getAttributeExpression(RATE_ATT_NAME).expressionAsAssignment»
				</RATE>
			«ENDIF»
			«IF hasAttribute(DURATION_ATT_NAME)»
				<Rate>
					«getAttributeExpression(DURATION_ATT_NAME).expressionAsAssignment»
				</RATE>
			«ENDIF»
		</Infusion>
		'''
		]
	}

	def writeInterventionCombination(ListDefinition it)'''
		<InterventionsCombination oid="«name»">
			<Interventions>
				«IF firstAttributeList.getAttributeExpression(COMBINATION_ATT_NAME).vector != null»
					«FOR expr : firstAttributeList.getAttributeExpression(COMBINATION_ATT_NAME).vector»
						<InterventionRef oidRef="«expr.symbolRef?.ref.name»"/>
					«ENDFOR»
					«IF firstAttributeList.hasAttribute(START_ATT_NAME)»
						<Start>
							«firstAttributeList.getAttributeExpression(START_ATT_NAME).expressionAsAssignment»
						</Start>
					«ENDIF»
					«IF firstAttributeList.hasAttribute(END_ATT_NAME)»
						<End>
							«firstAttributeList.getAttributeExpression(END_ATT_NAME).expressionAsAssignment»
						</End>
					«ENDIF»
				«ENDIF»
			</Interventions>
		</InterventionsCombination>
	'''
	
	def writeAdministration(ListDefinition it, (AttributeList) => String dosingLambda)'''
		<Administration oid="«name»">
			«dosingLambda.apply(firstAttributeList)»
		</Administration>
		'''

	def writeAction(ListDefinition it, (AttributeList) => String resetLambda)'''
		<Action oid="«name»">
			«resetLambda.apply(firstAttributeList)»
		</Action>
		'''


	def writeReset(ListDefinition ld){
		ld.writeAction[
		'''
			<Washout>
				«FOR vtr : getAttributeExpression(RESET_ATT).vector»
					<VariableToReset>
						«IF vtr instanceof SubListExpression»
							«vtr.getModelVar(RESET_VARIABLE).symbolReference»
							«IF vtr.hasAttribute(RESET_VALUE_ATT)»
								<ResetValue>
									«vtr.getAttributeExpression(RESET_VALUE_ATT).pharmMLExpr»
								</ResetValue>
							«ENDIF»
							«IF vtr.hasAttribute(RESET_TIME_ATT)»
								<ResetTime>
									«vtr.getAttributeExpression(RESET_TIME_ATT).pharmMLExpr»
								</ResetTime>
							«ENDIF»
						«ENDIF»
					</VariableToReset>
				«ENDFOR»
			</Washout>
		'''
		]
	}

	def writeResetAll(ListDefinition ld){
		ld.writeAction[
		'''
			<Washout>
				<VariableToReset>
					<FullReset/>
				</VariableToReset>
			</Washout>
		'''
		]
	}

	def writeStudyDesign(BlockStatement studyDesignBlk)'''
		<Arms>
			«FOR stmt : studyDesignBlk.statements.filter[it instanceof PropertyStatement]»
				«IF stmt instanceof PropertyStatement»
					«FOR prop : stmt.properties»
						«writeStudyDesignProperty(prop)»
					«ENDFOR»
				«ENDIF»
			«ENDFOR»
			«FOR stmt : studyDesignBlk.statements.filter[it instanceof ListDefinition]»
				«IF stmt instanceof ListDefinition»
					«writeArm(stmt)»
				«ENDIF»
			«ENDFOR»
		</Arms>
	'''

	def writeArm(ListDefinition it)'''
		<Arm oid="«name»">
			<ArmSize>
				«firstAttributeList.getAttributeExpression(ARM_SIZE_ATT).expressionAsAssignment»
			</ArmSize>
			«FOR intSeqSl : firstAttributeList.getAttributeExpression(INTSEQ_ATT).vector»
				<InterventionSequence>
					«IF intSeqSl instanceof SubListExpression»
						<InterventionList>
							«FOR intRef : intSeqSl.getAttributeExpression(INTSEQ_ADMIN_ATT).vector»
								<InterventionRef oidRef="«intRef.symbolRef?.ref?.name?: 'Error!'»"/>
							«ENDFOR»
						</InterventionList>
						«IF intSeqSl.hasAttribute(START_ATT_NAME)»
							<Start>
								«intSeqSl.getAttributeExpression(START_ATT_NAME).expressionAsAssignment»
							</Start>
						«ENDIF»
					«ENDIF»
				</InterventionSequence>
			«ENDFOR»
			«FOR obsSeqSl : firstAttributeList.getAttributeExpression(SAMPSEQ_ATT).vector»
				<ObservationSequence>
					«IF obsSeqSl instanceof SubListExpression»
						<ObservationList>
							«FOR obsRef : obsSeqSl.getAttributeExpression(TrialDesignDesignObjectPrinter::SAMPSEQ_SAMP_ATT).vector»
								<ObservationRef oidRef="«obsRef.symbolRef?.ref?.name?: 'Error!'»"/>
							«ENDFOR»
						</ObservationList>
						«IF obsSeqSl.hasAttribute(START_ATT_NAME)»
							<Start>
								«obsSeqSl.getAttributeExpression(START_ATT_NAME).expressionAsAssignment»
							</Start>
						«ENDIF»
					«ENDIF»
				</ObservationSequence>
			«ENDFOR»
		</Arm>
	'''
		
	def writeStudyDesignProperty(ValuePair it){
		switch(argumentName){
			case(TOTAL_COST_PROP):
				writeProperty('TotalCost', expression)
			case(TOTAL_SIZE_PROP):
				writeProperty('TotalSize', expression)
			case(NUM_ARMS_PROP):
				writeProperty('NumberArms', expression)
			case(NUM_SAMPLES_PROP):
				writeProperty('NumberSamples', expression)
			case(SAME_TIMES_PROP):
				writeProperty('SameTimes', expression)
		}
	}
	
	
	def private writeProperty(String element, Expression value)'''
		<«element»>
			«value.expressionAsAssignment»
		</«element»>
	'''
		
	

}