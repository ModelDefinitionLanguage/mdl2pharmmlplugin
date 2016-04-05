package eu.ddmore.converter.mdl2pharmml08

import com.google.inject.Inject
import eu.ddmore.mdl.MdlAndLibInjectorProvider
import eu.ddmore.mdl.mdl.AssignPair
import eu.ddmore.mdl.mdl.BlockStatement
import eu.ddmore.mdl.mdl.BlockStatementBody
import eu.ddmore.mdl.mdl.EnumPair
import eu.ddmore.mdl.mdl.MdlFactory
import eu.ddmore.mdl.mdl.SymbolReference
import eu.ddmore.mdl.provider.BlockDefinitionTable
import eu.ddmore.mdllib.mdllib.Expression
import eu.ddmore.mdllib.mdllib.MdlLibFactory
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertEquals

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(MdlAndLibInjectorProvider))
class ListObservationsWriterTest {
	@Inject extension ListObservationsWriter
	
	@Test
	def void testWriteCombinedError2NoTrans(){
		val obsBlk = createBlock(BlockDefinitionTable::OBS_BLK_NAME)
		val mPredBlk = createBlock(BlockDefinitionTable::MDL_PRED_BLK_NAME)
		val mParamsBlk = createBlock(BlockDefinitionTable::MDL_STRUCT_PARAMS)
		val rvBlk = createBlock(BlockDefinitionTable::MDL_RND_VARS)
		val ld = MdlFactory.eINSTANCE.createListDefinition
		val bdy = (obsBlk.body as BlockStatementBody)
		bdy.statements.add(ld)
		val attList = MdlFactory.eINSTANCE.createAttributeList
		ld.setName("tst")
		ld.list = attList
		attList.attributes.add(createEnumPair('type', 'combinedError2'))
		attList.attributes.add(createAssignPair('additive', mParamsBlk.createSymbolRef('A')))
		attList.attributes.add(createAssignPair('proportional', mParamsBlk.createSymbolRef('B')))
		attList.attributes.add(createAssignPair('eps', rvBlk.createSymbolRef('E')))
		attList.attributes.add(createAssignPair('prediction', mPredBlk.createSymbolRef('C')))
		
		val actual = writeListObservations(ld, 1)
		val expected = '''
		<ObservationModel blkId="om1">
			<ContinuousData>
				<Standard symbId="tst">
					<Output>
						<ct:SymbRef blkIdRef="sm" symbIdRef="C"/>
					</Output>
					<ErrorModel>
						<ct:Assign>
							<math:FunctionCall>
								<ct:SymbRef symbIdRef="combinedError2"/>
								<math:FunctionArgument symbId="additive">
									<ct:SymbRef blkIdRef="pm" symbIdRef="A"/>
								</math:FunctionArgument>
								<math:FunctionArgument symbId="proportional">
									<ct:SymbRef blkIdRef="pm" symbIdRef="B"/>
								</math:FunctionArgument>
								<math:FunctionArgument symbId="f">
									<ct:SymbRef blkIdRef="sm" symbIdRef="C"/>
								</math:FunctionArgument>
							</math:FunctionCall>
						</ct:Assign>
					</ErrorModel>
					<ResidualError>
						<ct:SymbRef blkIdRef="pm" symbIdRef="E"/>
					</ResidualError>
				</Standard>
			</ContinuousData>
		</ObservationModel>
		'''
		assertEquals("Output as expected", expected, actual.toString)
	}

	@Test
	def void testWriteCombinedError2LogRhsTrans(){
		val obsBlk = createBlock(BlockDefinitionTable::OBS_BLK_NAME)
		val mPredBlk = createBlock(BlockDefinitionTable::MDL_PRED_BLK_NAME)
		val mParamsBlk = createBlock(BlockDefinitionTable::MDL_STRUCT_PARAMS)
		val rvBlk = createBlock(BlockDefinitionTable::MDL_RND_VARS)
		val ld = MdlFactory.eINSTANCE.createListDefinition
		val bdy = (obsBlk.body as BlockStatementBody)
		bdy.statements.add(ld)
		val attList = MdlFactory.eINSTANCE.createAttributeList
		ld.setName("tst")
		ld.list = attList
		attList.attributes.add(createEnumPair('type', 'combinedError2'))
		attList.attributes.add(createEnumPair('trans', 'ln'))
		attList.attributes.add(createAssignPair('additive', mParamsBlk.createSymbolRef('A')))
		attList.attributes.add(createAssignPair('proportional', mParamsBlk.createSymbolRef('B')))
		attList.attributes.add(createAssignPair('eps', rvBlk.createSymbolRef('E')))
		attList.attributes.add(createAssignPair('prediction', mPredBlk.createSymbolRef('C')))
		
		val actual = writeListObservations(ld, 1)
		val expected = '''
		<ObservationModel blkId="om1">
			<ContinuousData>
				<ct:Variable symbolType="real" symbId="C">
					<ct:Assign>
						<math:Uniop op="log">
							<ct:SymbRef blkIdRef="sm" symbIdRef="C"/>
						</math:Uniop>
					</ct:Assign>
				</ct:Variable>
				<Standard symbId="tst">
					<Output>
						<ct:SymbRef symbIdRef="C"/>
					</Output>
					<ErrorModel>
						<ct:Assign>
							<math:FunctionCall>
								<ct:SymbRef symbIdRef="combinedError2Log"/>
								<math:FunctionArgument symbId="additive">
									<ct:SymbRef blkIdRef="pm" symbIdRef="A"/>
								</math:FunctionArgument>
								<math:FunctionArgument symbId="proportional">
									<ct:SymbRef blkIdRef="pm" symbIdRef="B"/>
								</math:FunctionArgument>
								<math:FunctionArgument symbId="f">
									<ct:SymbRef blkIdRef="sm" symbIdRef="C"/>
								</math:FunctionArgument>
							</math:FunctionCall>
						</ct:Assign>
					</ErrorModel>
					<ResidualError>
						<ct:SymbRef blkIdRef="pm" symbIdRef="E"/>
					</ResidualError>
				</Standard>
			</ContinuousData>
		</ObservationModel>
		'''
		assertEquals("Output as expected", expected, actual.toString)
	}


	@Test
	def void testWriteCombinedError2LogBothTrans(){
		val obsBlk = createBlock(BlockDefinitionTable::OBS_BLK_NAME)
		val mPredBlk = createBlock(BlockDefinitionTable::MDL_PRED_BLK_NAME)
		val mParamsBlk = createBlock(BlockDefinitionTable::MDL_STRUCT_PARAMS)
		val rvBlk = createBlock(BlockDefinitionTable::MDL_RND_VARS)
		val ld = MdlFactory.eINSTANCE.createListDefinition
		val bdy = (obsBlk.body as BlockStatementBody)
		bdy.statements.add(ld)
		val attList = MdlFactory.eINSTANCE.createAttributeList
		ld.setName("tst")
		ld.list = attList
		attList.attributes.add(createEnumPair('type', 'combinedError2'))
		attList.attributes.add(createEnumPair('lhsTrans', 'ln'))
		attList.attributes.add(createEnumPair('trans', 'ln'))
		attList.attributes.add(createAssignPair('additive', mParamsBlk.createSymbolRef('A')))
		attList.attributes.add(createAssignPair('proportional', mParamsBlk.createSymbolRef('B')))
		attList.attributes.add(createAssignPair('eps', rvBlk.createSymbolRef('E')))
		attList.attributes.add(createAssignPair('prediction', mPredBlk.createSymbolRef('C')))
		
		val actual = writeListObservations(ld, 1)
		val expected = '''
		<ObservationModel blkId="om1">
			<ContinuousData>
				<Standard symbId="tst">
					<Transformation type="log"/>
					<Output>
						<ct:SymbRef blkIdRef="sm" symbIdRef="C"/>
					</Output>
					<ErrorModel>
						<ct:Assign>
							<math:FunctionCall>
								<ct:SymbRef symbIdRef="combinedError2Log"/>
								<math:FunctionArgument symbId="additive">
									<ct:SymbRef blkIdRef="pm" symbIdRef="A"/>
								</math:FunctionArgument>
								<math:FunctionArgument symbId="proportional">
									<ct:SymbRef blkIdRef="pm" symbIdRef="B"/>
								</math:FunctionArgument>
								<math:FunctionArgument symbId="f">
									<ct:SymbRef blkIdRef="sm" symbIdRef="C"/>
								</math:FunctionArgument>
							</math:FunctionCall>
						</ct:Assign>
					</ErrorModel>
					<ResidualError>
						<ct:SymbRef blkIdRef="pm" symbIdRef="E"/>
					</ResidualError>
				</Standard>
			</ContinuousData>
		</ObservationModel>
		'''
		assertEquals("Output as expected", expected, actual.toString)
	}



	def BlockStatement createBlock(String blkName){
		val retVal = MdlFactory.eINSTANCE.createBlockStatement
		val blkDefn = MdlLibFactory.eINSTANCE.createBlockDefinition
		blkDefn.name = blkName
		retVal.blkId = blkDefn
		retVal.body = MdlFactory.eINSTANCE.createBlockStatementBody
		retVal
	}
	
	def private EnumPair createEnumPair(String name, String value){
		val retVal = MdlFactory.eINSTANCE.createEnumPair
		retVal.argumentName = name
		val enumExpr =  MdlFactory.eINSTANCE.createEnumExpression
		enumExpr.enumValue = value
		retVal.expression = enumExpr
		retVal
	}
	
	def private AssignPair createAssignPair(String name, Expression exprVal){
		val retVal = MdlFactory.eINSTANCE.createAssignPair
		retVal.argumentName = name
		retVal.expression = exprVal
		retVal
	}
	
	def private SymbolReference createSymbolRef(BlockStatement it, String name){
		val bdy = body as BlockStatementBody
		val sd = MdlFactory.eINSTANCE.createEquationDefinition
		sd.name = name
		bdy.statements.add(sd)
		val retVal = MdlFactory.eINSTANCE.createSymbolReference
		retVal.ref = sd
		retVal
	}
}