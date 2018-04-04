package eu.ddmore.converter.mdl2pharmml08

import com.google.inject.Inject
import eu.ddmore.mdl.tests.MdlAndLibInjectorProvider
import eu.ddmore.mdl.mdl.Mcl
import eu.ddmore.mdl.mdl.MclObject
import eu.ddmore.mdl.provider.BlockDefinitionTable
import eu.ddmore.mdl.utils.LibraryUtils
import eu.ddmore.mdl.utils.MDLBuildFixture
import eu.ddmore.mdl.utils.MdlLibUtils
import eu.ddmore.mdllib.mdllib.Library
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertEquals
import org.eclipse.xtext.junit4.TemporaryFolder
import java.nio.file.Paths

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(MdlAndLibInjectorProvider))
class PriorParameterWriterTest {
	@Inject extension MDLBuildFixture
	@Inject extension MdlTestHelper<Mcl>
	@Inject extension MdlLibUtils
	@Inject extension LibraryUtils
	
	var Library libDefns
	var PriorParameterWriter testInstance

	@Rule
	public val TemporaryFolder folder = new TemporaryFolder() 
	
	@Before
	def void setUp(){
				val dummyMdl = '''
			foo = mdlObj {
				
			}
		'''.parse
		
		libDefns = dummyMdl.objects.head.libraryForObject
		
	}
	
	@After
	def void tearDown(){
		libDefns = null
	}

	@Test
	def void testWritePriorDistn(){
		val root = createRoot
		val priorObj = root.createObject("pObj", libDefns.getObjectDefinition('priorObj'))
		val priorBlk = priorObj.createBlock(libDefns.getBlockDefinition(BlockDefinitionTable::PRIOR_VAR_DEFN))
		priorBlk.createRandVar('p1',
							createNamedFunction(libDefns.getFunctionDefinition('Gamma2'),
									createAssignPair('shape', createRealLiteral(2.0)),
									createAssignPair('rate', createRealLiteral(3.0))
							)
						)
		
		val mdlObj = root.createObject("mObj", libDefns.getObjectDefinition('mdlObj'))
		val paramBlk = mdlObj.createBlock(libDefns.getBlockDefinition(BlockDefinitionTable::MDL_STRUCT_PARAMS))
		val parmStmt = paramBlk.createEqnDefn('p1')
		
		
		this.testInstance = new PriorParameterWriter(null, priorObj)
		val actual = testInstance.writeParameter(parmStmt)
		val expected = '''
			<PopulationParameter symbId="p1">
				<ct:VariabilityReference>
					<ct:SymbRef blkIdRef="vm_mdl" symbIdRef="MDL__prior"/>
				</ct:VariabilityReference>
				<Distribution>
					<ProbOnto xmlns="http://www.pharmml.org/probonto/ProbOnto" name="Gamma2">
						<Parameter name="shape">
							<ct:Assign>
								<ct:Real>2.0</ct:Real>
							</ct:Assign>
						</Parameter>
						<Parameter name="rate">
							<ct:Assign>
								<ct:Real>3.0</ct:Real>
							</ct:Assign>
						</Parameter>
					</ProbOnto>
				</Distribution>
			</PopulationParameter>
		'''
		assertEquals("Output as expected", expected, actual.toString)
	}


	@Test
	def void testWritePriorWithMathsExpr(){
		val root = createRoot
		val priorObj = root.createObject("pObj", libDefns.getObjectDefinition('priorObj'))
		val priorBlk = priorObj.createBlock(libDefns.getBlockDefinition(BlockDefinitionTable::PRIOR_VAR_DEFN))
		val symbRef = priorBlk.createEqnDefn("anOther", createRealLiteral(2.0))
		priorBlk.createEqnDefn('p1', symbRef.createSymbolRef)
		
		val mdlObj = root.createObject("mObj", libDefns.getObjectDefinition('mdlObj'))
		val paramBlk = mdlObj.createBlock(libDefns.getBlockDefinition(BlockDefinitionTable::MDL_STRUCT_PARAMS))
		val parmStmt = paramBlk.createEqnDefn('p1')
		
		
		this.testInstance = new PriorParameterWriter(null, priorObj)
		val actual = testInstance.writeParameter(parmStmt)
		val expected = '''
			<PopulationParameter symbId="p1">
				<ct:Assign>
					<ct:SymbRef blkIdRef="pm" symbIdRef="anOther"/>
				</ct:Assign>
			</PopulationParameter>
		'''
		assertEquals("Output as expected", expected, actual.toString)
	}


	@Test
	def void testWritePriorWithLiteral(){
		val root = createRoot
		val priorObj = root.createObject("pObj", libDefns.getObjectDefinition('priorObj'))
		val priorBlk = priorObj.createBlock(libDefns.getBlockDefinition(BlockDefinitionTable::PRIOR_VAR_DEFN))
		priorBlk.createEqnDefn('p1',createRealLiteral(2.0))
		
		val mdlObj = root.createObject("mObj", libDefns.getObjectDefinition('mdlObj'))
		val paramBlk = mdlObj.createBlock(libDefns.getBlockDefinition(BlockDefinitionTable::MDL_STRUCT_PARAMS))
		val parmStmt = paramBlk.createEqnDefn('p1')
		
		
		this.testInstance = new PriorParameterWriter(null, priorObj)
		val actual = testInstance.writeParameter(parmStmt)
		val expected = '''
			<PopulationParameter symbId="p1">
				<ct:Assign>
					<ct:Real>2.0</ct:Real>
				</ct:Assign>
			</PopulationParameter>
		'''
		assertEquals("Output as expected", expected, actual.toString)
	}


	@Test
	def void testWriteParamNotInPriorObj(){
		val root = createRoot
		val priorObj = root.createObject("pObj", libDefns.getObjectDefinition('priorObj'))
		val priorBlk = priorObj.createBlock(libDefns.getBlockDefinition(BlockDefinitionTable::PRIOR_VAR_DEFN))
		priorBlk.createEqnDefn('p111',createRealLiteral(2.0))
		
		val mdlObj = root.createObject("mObj", libDefns.getObjectDefinition('mdlObj'))
		val paramBlk = mdlObj.createBlock(libDefns.getBlockDefinition(BlockDefinitionTable::MDL_STRUCT_PARAMS))
		val parmStmt = paramBlk.createEqnDefn('p1', createRealLiteral(22.0))
		
		
		this.testInstance = new PriorParameterWriter(null, priorObj)
		val actual = testInstance.writeParameter(parmStmt)
		val expected = '''
			<PopulationParameter symbId="p1">
				<ct:Assign>
					<ct:Real>22.0</ct:Real>
				</ct:Assign>
			</PopulationParameter>
		'''
		assertEquals("Output as expected", expected, actual.toString)
	}

	def createDataset(MclObject priorObj, String fileName){
		val priorParams = priorObj.createBlock(libDefns.getBlockDefinition(BlockDefinitionTable::PRIOR_PARAMS))
		
		val kaVProps = priorParams.createEqnDefn("KA_V_PROBS")
		val kaVBins = priorParams.createEqnDefn("KA_V_BINS")
		val tlag_BINS = priorParams.createEqnDefn("TLAG_BINS")
		
		val priorNcDBlk = priorObj.createBlock(libDefns.getBlockDefinition(BlockDefinitionTable::PRIOR_NC_DISTN))
		val priorSrcBlk = priorNcDBlk.createBlock(libDefns.getBlockDefinition(BlockDefinitionTable::PRIOR_SOURCE_BLK))
		
		val dataList = priorSrcBlk.createListDefn("d1", createAssignPair('file', createStringLiteral(fileName)),
				createEnumPair("input", "csv"), 
				createAssignPair("column", createVectorLiteral(createStringLiteral("p_ka_v"), createStringLiteral("bin_ka"), 
				createStringLiteral("bin_v"), createStringLiteral("bin_tlag")))
		)
		
		val ipdBlk = priorNcDBlk.createBlock(libDefns.getBlockDefinition(BlockDefinitionTable::PRIOR_INPUT_DATA))		
		
		ipdBlk.createAnonList(createAssignPair("vectorVar", createSymbolRef(kaVProps)), 
				createAssignPair("src", createSymbolRef(dataList)),
				createAssignPair("column", createStringLiteral("p_ka_v"))
		)
		ipdBlk.createAnonList(createAssignPair("matrixVar", createSymbolRef(kaVBins)), 
				createAssignPair("src", createSymbolRef(dataList)),
				createAssignPair("column",
					createVectorLiteral(
						createStringLiteral("bin_ka"),
						createStringLiteral("bin_v")
					)
				)
		)
		ipdBlk.createAnonList(createAssignPair("vectorVar", createSymbolRef(tlag_BINS)), 
				createAssignPair("src", createSymbolRef(dataList)),
				createAssignPair("column", createStringLiteral("bin_tlag"))
		)
		dataList
	}

	@Test
	def void testWriteParamFromData(){
		val root = createRoot
		val priorObj = root.createObject("pObj", libDefns.getObjectDefinition('priorObj'))
		val currDir = Paths.get("").toAbsolutePath;
		val mdlFile = Paths.get(currDir.toString, "tst.mdl")
		val pharmmlFile = Paths.get(currDir.toString, "pharmml", "tst.xml")
		this.testInstance = new PriorParameterWriter(null, priorObj, false, mdlFile, pharmmlFile)
		val dataFileName = "simple3_prior.csv"
		val dataset = createDataset(priorObj, dataFileName)
		val expectedDataPath = Paths.get("..", dataFileName)
		val actual = testInstance.writeDataset(dataset)
		val expected = '''
		<ExternalDataSet oid="d1">
			<ColumnMapping>
				<ds:ColumnRef columnIdRef="p_ka_v"/>
				<ct:SymbRef blkIdRef="pm" symbIdRef="KA_V_PROBS"/>
			</ColumnMapping>
			<ColumnMapping>
				<ds:ColumnRef columnIdRef="bin_ka"/>
				<ct:Assign>
					<ct:VectorSelector>
						<ct:SymbRef blkIdRef="pm" symbIdRef="KA_V_BINS"/>
						<ct:Cell>
							<ct:Int>1</ct:Int>
						</ct:Cell>
					</ct:VectorSelector>
				</ct:Assign>
			</ColumnMapping>
			<ColumnMapping>
				<ds:ColumnRef columnIdRef="bin_v"/>
				<ct:Assign>
					<ct:VectorSelector>
						<ct:SymbRef blkIdRef="pm" symbIdRef="KA_V_BINS"/>
						<ct:Cell>
							<ct:Int>2</ct:Int>
						</ct:Cell>
					</ct:VectorSelector>
				</ct:Assign>
			</ColumnMapping>
			<ColumnMapping>
				<ds:ColumnRef columnIdRef="bin_tlag"/>
				<ct:SymbRef blkIdRef="pm" symbIdRef="TLAG_BINS"/>
			</ColumnMapping>
			<ds:DataSet>
				<ds:Definition>
					<ds:Column columnId="p_ka_v" valueType="real" columnNum="1" columnType="undefined"/>
					<ds:Column columnId="bin_ka" valueType="real" columnNum="2" columnType="undefined"/>
					<ds:Column columnId="bin_v" valueType="real" columnNum="3" columnType="undefined"/>
					<ds:Column columnId="bin_tlag" valueType="real" columnNum="4" columnType="undefined"/>
				</ds:Definition>
				<ds:ExternalFile oid="MDL__fileOid_d1">
					<ds:path>«expectedDataPath»</ds:path>
					<ds:format>CSV</ds:format>
					<ds:delimiter>COMMA</ds:delimiter>
				</ds:ExternalFile>
			</ds:DataSet>
		</ExternalDataSet>
		'''
		assertEquals("Output as expected", expected, actual.toString)
	}


	@Test
	def void testWriteParamFromDataRelativeToAbs(){
		val root = createRoot
		val priorObj = root.createObject("pObj", libDefns.getObjectDefinition('priorObj'))
		val currDir = Paths.get("").toAbsolutePath;
		val mdlFile = Paths.get(currDir.toString, "tst.mdl")
		val pharmmlFile = Paths.get(currDir.toString, "pharmml", "tst.xml")
		this.testInstance = new PriorParameterWriter(null, priorObj, true, mdlFile, pharmmlFile)
		val dataFileName = "simple3_prior.csv"
		val dataset = createDataset(priorObj, dataFileName)
		val expectedDataPath = Paths.get("", dataFileName).toAbsolutePath.normalize
		val actual = testInstance.writeDataset(dataset)
		val expected = '''
		<ExternalDataSet oid="d1">
			<ColumnMapping>
				<ds:ColumnRef columnIdRef="p_ka_v"/>
				<ct:SymbRef blkIdRef="pm" symbIdRef="KA_V_PROBS"/>
			</ColumnMapping>
			<ColumnMapping>
				<ds:ColumnRef columnIdRef="bin_ka"/>
				<ct:Assign>
					<ct:VectorSelector>
						<ct:SymbRef blkIdRef="pm" symbIdRef="KA_V_BINS"/>
						<ct:Cell>
							<ct:Int>1</ct:Int>
						</ct:Cell>
					</ct:VectorSelector>
				</ct:Assign>
			</ColumnMapping>
			<ColumnMapping>
				<ds:ColumnRef columnIdRef="bin_v"/>
				<ct:Assign>
					<ct:VectorSelector>
						<ct:SymbRef blkIdRef="pm" symbIdRef="KA_V_BINS"/>
						<ct:Cell>
							<ct:Int>2</ct:Int>
						</ct:Cell>
					</ct:VectorSelector>
				</ct:Assign>
			</ColumnMapping>
			<ColumnMapping>
				<ds:ColumnRef columnIdRef="bin_tlag"/>
				<ct:SymbRef blkIdRef="pm" symbIdRef="TLAG_BINS"/>
			</ColumnMapping>
			<ds:DataSet>
				<ds:Definition>
					<ds:Column columnId="p_ka_v" valueType="real" columnNum="1" columnType="undefined"/>
					<ds:Column columnId="bin_ka" valueType="real" columnNum="2" columnType="undefined"/>
					<ds:Column columnId="bin_v" valueType="real" columnNum="3" columnType="undefined"/>
					<ds:Column columnId="bin_tlag" valueType="real" columnNum="4" columnType="undefined"/>
				</ds:Definition>
				<ds:ExternalFile oid="MDL__fileOid_d1">
					<ds:path>«expectedDataPath»</ds:path>
					<ds:format>CSV</ds:format>
					<ds:delimiter>COMMA</ds:delimiter>
				</ds:ExternalFile>
			</ds:DataSet>
		</ExternalDataSet>
		'''
		assertEquals("Output as expected", expected, actual.toString)
	}


	@Test
	def void testWriteParamFromDataWithAbsoluteUrl(){
		val root = createRoot
		val priorObj = root.createObject("pObj", libDefns.getObjectDefinition('priorObj'))
		this.testInstance = new PriorParameterWriter(null, priorObj)
		val dataset = createDataset(priorObj, "/foo/bar/absolute/simple3_prior.csv")
		val actual = testInstance.writeDataset(dataset)
		val expected = '''
		<ExternalDataSet oid="d1">
			<ColumnMapping>
				<ds:ColumnRef columnIdRef="p_ka_v"/>
				<ct:SymbRef blkIdRef="pm" symbIdRef="KA_V_PROBS"/>
			</ColumnMapping>
			<ColumnMapping>
				<ds:ColumnRef columnIdRef="bin_ka"/>
				<ct:Assign>
					<ct:VectorSelector>
						<ct:SymbRef blkIdRef="pm" symbIdRef="KA_V_BINS"/>
						<ct:Cell>
							<ct:Int>1</ct:Int>
						</ct:Cell>
					</ct:VectorSelector>
				</ct:Assign>
			</ColumnMapping>
			<ColumnMapping>
				<ds:ColumnRef columnIdRef="bin_v"/>
				<ct:Assign>
					<ct:VectorSelector>
						<ct:SymbRef blkIdRef="pm" symbIdRef="KA_V_BINS"/>
						<ct:Cell>
							<ct:Int>2</ct:Int>
						</ct:Cell>
					</ct:VectorSelector>
				</ct:Assign>
			</ColumnMapping>
			<ColumnMapping>
				<ds:ColumnRef columnIdRef="bin_tlag"/>
				<ct:SymbRef blkIdRef="pm" symbIdRef="TLAG_BINS"/>
			</ColumnMapping>
			<ds:DataSet>
				<ds:Definition>
					<ds:Column columnId="p_ka_v" valueType="real" columnNum="1" columnType="undefined"/>
					<ds:Column columnId="bin_ka" valueType="real" columnNum="2" columnType="undefined"/>
					<ds:Column columnId="bin_v" valueType="real" columnNum="3" columnType="undefined"/>
					<ds:Column columnId="bin_tlag" valueType="real" columnNum="4" columnType="undefined"/>
				</ds:Definition>
				<ds:ExternalFile oid="MDL__fileOid_d1">
					<ds:path>/foo/bar/absolute/simple3_prior.csv</ds:path>
					<ds:format>CSV</ds:format>
					<ds:delimiter>COMMA</ds:delimiter>
				</ds:ExternalFile>
			</ds:DataSet>
		</ExternalDataSet>
		'''
		assertEquals("Output as expected", expected, actual.toString)
	}

	@Test
	def void testWriteVarLevels(){
		val root = createRoot
		val priorObj = root.createObject("pObj", libDefns.getObjectDefinition('priorObj'))
		
		val mdlObj = root.createObject("mObj", libDefns.getObjectDefinition('mdlObj'))
		val varLvlBlk = mdlObj.createBlock(libDefns.getBlockDefinition(BlockDefinitionTable::VAR_LVL_BLK_NAME))
		varLvlBlk.createListDefn("bsv", createEnumPair('type', 'parameter'), createAssignPair('level', createIntLiteral(1)))
		
		this.testInstance = new PriorParameterWriter(mdlObj, priorObj)
		val actual = testInstance.writeVariabilityModel
		val expected = '''
			<VariabilityModel blkId="vm_mdl" type="parameterVariability">
				<Level symbId="MDL__prior"/>
				<Level symbId="bsv">
					<ParentLevel>
						<ct:SymbRef symbIdRef="MDL__prior"/>
					</ParentLevel>
				</Level>
			</VariabilityModel>
		'''
		assertEquals("Output as expected", expected, actual.toString)
	}

	@Test
	def void testWriteVarLevelWithReference(){
		val root = createRoot
		val priorObj = root.createObject("pObj", libDefns.getObjectDefinition('priorObj'))
		
		val mdlObj = root.createObject("mObj", libDefns.getObjectDefinition('mdlObj'))
		val varLvlBlk = mdlObj.createBlock(libDefns.getBlockDefinition(BlockDefinitionTable::VAR_LVL_BLK_NAME))
		val bsvLvl = varLvlBlk.createListDefn("bsv", createEnumPair('type', 'parameter'), createAssignPair('level', createIntLiteral(1)))
		varLvlBlk.addArguments(createAssignPair('reference', bsvLvl.createSymbolRef))
		
		this.testInstance = new PriorParameterWriter(mdlObj, priorObj)
		val actual = testInstance.writeVariabilityModel
		val expected = '''
			<VariabilityModel blkId="vm_mdl" type="parameterVariability">
				<Level symbId="MDL__prior"/>
				<Level referenceLevel="true" symbId="bsv">
					<ParentLevel>
						<ct:SymbRef symbIdRef="MDL__prior"/>
					</ParentLevel>
				</Level>
			</VariabilityModel>
		'''
		assertEquals("Output as expected", expected, actual.toString)
	}



}