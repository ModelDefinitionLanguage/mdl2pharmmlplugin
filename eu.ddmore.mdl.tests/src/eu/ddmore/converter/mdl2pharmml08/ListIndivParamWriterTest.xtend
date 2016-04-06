package eu.ddmore.converter.mdl2pharmml08

import com.google.inject.Inject
import eu.ddmore.mdl.MdlAndLibInjectorProvider
import eu.ddmore.mdl.mdl.BlockStatementBody
import eu.ddmore.mdl.mdl.MdlFactory
import eu.ddmore.mdl.provider.BlockDefinitionTable
import eu.ddmore.mdl.utils.MDLBuildFixture
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertEquals

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(MdlAndLibInjectorProvider))
class ListIndivParamWriterTest {
	@Inject extension ListIndivParamWriter
	@Inject extension MDLBuildFixture
	
	@Test
	def void testWriteIndivParamLinearNoTrans(){
		val obsBlk = createBlock(BlockDefinitionTable::MDL_INDIV_PARAMS)
		val covBlk = createBlock(BlockDefinitionTable::COVARIATE_BLK_NAME)
		val mParamsBlk = createBlock(BlockDefinitionTable::MDL_STRUCT_PARAMS)
		val rvBlk = createBlock(BlockDefinitionTable::MDL_RND_VARS)
		val ld = MdlFactory.eINSTANCE.createListDefinition
		val bdy = (obsBlk.body as BlockStatementBody)
		bdy.statements.add(ld)
		val attList = MdlFactory.eINSTANCE.createAttributeList
		ld.setName("CL")
		ld.list = attList
		attList.attributes.add(createEnumPair('type', 'linear'))
		attList.attributes.add(createAssignPair('pop', mParamsBlk.createSymbolRef('A')))
		attList.attributes.add(createAssignPair('fixEff', createVectorLiteral(#[createSublist(#{ "cov"->covBlk.createSymbolRef("W"), 
																							"coeff"->mParamsBlk.createSymbolRef("BETA_W") })])))
		attList.attributes.add(createAssignPair('ranEff', createVectorLiteral(#[rvBlk.createSymbolRef('ETA')])))
		
		val actual = writeIndividualParameter(ld)
		val expected = '''
			<IndividualParameter symbId="CL">
				<StructuredModel>
					<LinearCovariate>
						<PopulationValue>
							<ct:Assign>
								<ct:SymbRef blkIdRef="pm" symbIdRef="A"/>
							</ct:Assign>
						</PopulationValue>
						<Covariate>
							<ct:SymbRef blkIdRef="cm" symbIdRef="W"/>
							<FixedEffect>
								<ct:SymbRef blkIdRef="pm" symbIdRef="BETA_W"/>
							</FixedEffect>
						</Covariate>
					</LinearCovariate>
					<RandomEffects>
						<ct:SymbRef blkIdRef="pm" symbIdRef="ETA"/>
					</RandomEffects>
				</StructuredModel>
			</IndividualParameter>
			'''
		assertEquals("Output as expected", expected, actual.toString)
	}

	@Test
	def void testWriteIndivParamLinearLogitTrans(){
		val obsBlk = createBlock(BlockDefinitionTable::MDL_INDIV_PARAMS)
		val covBlk = createBlock(BlockDefinitionTable::COVARIATE_BLK_NAME)
		val mParamsBlk = createBlock(BlockDefinitionTable::MDL_STRUCT_PARAMS)
		val rvBlk = createBlock(BlockDefinitionTable::MDL_RND_VARS)
		val ld = MdlFactory.eINSTANCE.createListDefinition
		val bdy = (obsBlk.body as BlockStatementBody)
		bdy.statements.add(ld)
		val attList = MdlFactory.eINSTANCE.createAttributeList
		ld.setName("CL")
		ld.list = attList
		attList.attributes.add(createEnumPair('type', 'linear'))
		attList.attributes.add(createEnumPair('trans', 'logit'))
		attList.attributes.add(createAssignPair('pop', mParamsBlk.createSymbolRef('A')))
		attList.attributes.add(createAssignPair('fixEff', createVectorLiteral(#[createSublist(#{ "cov"->covBlk.createSymbolRef("W"), 
																							"coeff"->mParamsBlk.createSymbolRef("BETA_W") })])))
		attList.attributes.add(createAssignPair('ranEff', createVectorLiteral(#[rvBlk.createSymbolRef('ETA')])))
		
		val actual = writeIndividualParameter(ld)
		val expected = '''
			<IndividualParameter symbId="CL">
				<StructuredModel>
					<Transformation type="logit" />
					<LinearCovariate>
						<PopulationValue>
							<ct:Assign>
								<ct:SymbRef blkIdRef="pm" symbIdRef="A"/>
							</ct:Assign>
						</PopulationValue>
						<Covariate>
							<ct:SymbRef blkIdRef="cm" symbIdRef="W"/>
							<FixedEffect>
								<ct:SymbRef blkIdRef="pm" symbIdRef="BETA_W"/>
							</FixedEffect>
						</Covariate>
					</LinearCovariate>
					<RandomEffects>
						<ct:SymbRef blkIdRef="pm" symbIdRef="ETA"/>
					</RandomEffects>
				</StructuredModel>
			</IndividualParameter>
			'''
		assertEquals("Output as expected", expected, actual.toString)
	}

	@Test
	def void testWriteIndivParamGeneralNoTrans(){
		val obsBlk = createBlock(BlockDefinitionTable::MDL_INDIV_PARAMS)
		val mParamsBlk = createBlock(BlockDefinitionTable::MDL_STRUCT_PARAMS)
		val rvBlk = createBlock(BlockDefinitionTable::MDL_RND_VARS)
		val ld = MdlFactory.eINSTANCE.createListDefinition
		val bdy = (obsBlk.body as BlockStatementBody)
		bdy.statements.add(ld)
		val attList = MdlFactory.eINSTANCE.createAttributeList
		ld.setName("CL")
		ld.list = attList
		attList.attributes.add(createEnumPair('type', 'general'))
		attList.attributes.add(createAssignPair('grp', mParamsBlk.createSymbolRef('A')))
		attList.attributes.add(createAssignPair('ranEff', createVectorLiteral(#[rvBlk.createSymbolRef('ETA')])))
		
		val actual = writeIndividualParameter(ld)
		val expected = '''
			<IndividualParameter symbId="CL">
				<StructuredModel>
					<GeneralCovariate>
						<ct:Assign>
							<ct:SymbRef blkIdRef="pm" symbIdRef="A"/>
						</ct:Assign>
					</GeneralCovariate>
					<RandomEffects>
						<ct:SymbRef blkIdRef="pm" symbIdRef="ETA"/>
					</RandomEffects>
				</StructuredModel>
			</IndividualParameter>
			'''
		assertEquals("Output as expected", expected, actual.toString)
	}

	@Test
	def void testWriteIndivParamGeneralLogitTrans(){
		val obsBlk = createBlock(BlockDefinitionTable::MDL_INDIV_PARAMS)
		val mParamsBlk = createBlock(BlockDefinitionTable::MDL_STRUCT_PARAMS)
		val rvBlk = createBlock(BlockDefinitionTable::MDL_RND_VARS)
		val ld = MdlFactory.eINSTANCE.createListDefinition
		val bdy = (obsBlk.body as BlockStatementBody)
		bdy.statements.add(ld)
		val attList = MdlFactory.eINSTANCE.createAttributeList
		ld.setName("CL")
		ld.list = attList
		attList.attributes.add(createEnumPair('type', 'general'))
		attList.attributes.add(createEnumPair('trans', 'logit'))
		attList.attributes.add(createAssignPair('grp', mParamsBlk.createSymbolRef('A')))
		attList.attributes.add(createAssignPair('ranEff', createVectorLiteral(#[rvBlk.createSymbolRef('ETA')])))
		
		val actual = writeIndividualParameter(ld)
		val expected = '''
			<IndividualParameter symbId="CL">
				<StructuredModel>
					<Transformation type="logit"/>
					<GeneralCovariate>
						<ct:Assign>
							<ct:SymbRef blkIdRef="pm" symbIdRef="A"/>
						</ct:Assign>
					</GeneralCovariate>
					<RandomEffects>
						<ct:SymbRef blkIdRef="pm" symbIdRef="ETA"/>
					</RandomEffects>
				</StructuredModel>
			</IndividualParameter>
			'''
		assertEquals("Output as expected", expected, actual.toString)
	}


}