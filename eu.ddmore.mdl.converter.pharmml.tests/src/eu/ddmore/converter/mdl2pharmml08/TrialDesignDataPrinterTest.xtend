package eu.ddmore.converter.mdl2pharmml08

import com.google.inject.Inject
import eu.ddmore.mdl.mdl.Mcl
import eu.ddmore.mdl.mdl.MclObject
import eu.ddmore.mdl.provider.BlockDefinitionTable
import eu.ddmore.mdl.tests.MdlAndLibInjectorProvider
import eu.ddmore.mdl.utils.LibraryUtils
import eu.ddmore.mdl.utils.MDLBuildFixture
import eu.ddmore.mdl.utils.MdlLibUtils
import eu.ddmore.mdllib.mdllib.Library
import java.nio.file.Path
import java.nio.file.Paths
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertEquals

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(MdlAndLibInjectorProvider))
class TrialDesignDataPrinterTest {
	@Inject extension MDLBuildFixture
	@Inject extension MdlTestHelper<Mcl>
	@Inject extension MdlLibUtils
	@Inject extension LibraryUtils

//	@Rule
//	public val TemporaryFolder folder = new TemporaryFolder() 
	
	var Library libDefns
	
	@Before
	def void setUp(){
				val dummyMdl = '''
			foo = mdlObj {
				
			}
		'''.parse
		
		libDefns = dummyMdl.objects.head.libraryForObject
		
	}
	
	def private createMogDefn(Mcl it, MclObject dataObj, MclObject mdlObj){
		val mogObj = createObject("fooMog", libDefns.getObjectDefinition("mogObj"))
		val objBlk = mogObj.createBlock(libDefns.getBlockDefinition(BlockDefinitionTable::MOG_OBJ_NAME))
		objBlk.createListDefn(dataObj.name, createEnumPair('type', 'dataObj'))
		objBlk.createListDefn(mdlObj.name, createEnumPair('type', 'mdlObj'))
		return mogObj
	}
	
	@Test
	def void testWriteDesignParametersRelativeNoPaths(){
		val mdl = createRoot
		val dataObj = mdl.createObject("foo", libDefns.getObjectDefinition("dataObj"))
		val mdlObj = mdl.createObject("foo2", libDefns.getObjectDefinition("mdlObj"))
		val mog = createMogDefn(mdl, dataObj, mdlObj)
		val desBlk = dataObj.createBlock(libDefns.getBlockDefinition(BlockDefinitionTable::DATA_SRC_BLK))
		desBlk.createListDefn(dataObj.name, createAssignPair("file", createStringLiteral("foo/bar.txt")),
			createEnumPair("inputFormat", "nonmemFormat")
		)
		
		val tdow = new TrialDesignDataObjectPrinter(mog, new StandardParameterWriter(null))
		val actual = tdow.writeTargetDataSet()
		val expected = '''
			<ExternalDataSet toolName="NONMEM" oid="nm_ds">
				<DataSet xmlns="http://www.pharmml.org/pharmml/0.8/Dataset">
					<Definition>
					</Definition>
					<ExternalFile oid="id">
						<path>foo/bar.txt</path>
						<format>CSV</format>
						<delimiter>COMMA</delimiter>
					</ExternalFile>
				</DataSet>
			</ExternalDataSet>
		'''
		assertEquals("Output as expected", expected, actual.toString)
	}

	@Test
	def void testWriteDesignParametersRelative(){
		// relatve locations
		//  mdl
		// data
		// pharmml1/pharmml2
		val mdl = createRoot
		val dataObj = mdl.createObject("foo", libDefns.getObjectDefinition("dataObj"))
		val mdlObj = mdl.createObject("foo2", libDefns.getObjectDefinition("mdlObj"))
		val mog = createMogDefn(mdl, dataObj, mdlObj)
		val desBlk = dataObj.createBlock(libDefns.getBlockDefinition(BlockDefinitionTable::DATA_SRC_BLK))
		val Path basePath = Paths.get("").toAbsolutePath
		val mdlFile = Paths.get(basePath.toString, "tst.mdl")
		val dataFile = Paths.get("data", "data.csv")
		val pharmFile = Paths.get(basePath.toString, "pharmml1", "pharmml2", "tst.xml")
//		val tstFile = folder.newFile("bar.txt")
//		val dataFile = new File(dataFolder, "data.csv")
//		dataFile.createNewFile
//		val pwd = Paths.get("").toAbsolutePath()
//		val relative = pwd.relativize(tstFile.toPath)
		desBlk.createListDefn(dataObj.name, createAssignPair("file", createStringLiteral(dataFile.toString)),
			createEnumPair("inputFormat", "nonmemFormat")
		)
		
		val tdow = new TrialDesignDataObjectPrinter(mog, new StandardParameterWriter(null), false, mdlFile, pharmFile)
		val actual = tdow.writeTargetDataSet()
		val expected = '''
			<ExternalDataSet toolName="NONMEM" oid="nm_ds">
				<DataSet xmlns="http://www.pharmml.org/pharmml/0.8/Dataset">
					<Definition>
					</Definition>
					<ExternalFile oid="id">
						<path>../../data/data.csv</path>
						<format>CSV</format>
						<delimiter>COMMA</delimiter>
					</ExternalFile>
				</DataSet>
			</ExternalDataSet>
		'''
		assertEquals("Output as expected", expected, actual.toString)
	}

	@Test
	def void testWriteDesignParametersRelativeInSameDir(){
		// Defines a relative path and then generates an absolute path from it.
		val mdl = createRoot
		val dataObj = mdl.createObject("foo", libDefns.getObjectDefinition("dataObj"))
		val mdlObj = mdl.createObject("foo2", libDefns.getObjectDefinition("mdlObj"))
		val mog = createMogDefn(mdl, dataObj, mdlObj)
		val desBlk = dataObj.createBlock(libDefns.getBlockDefinition(BlockDefinitionTable::DATA_SRC_BLK))
//		var fileName = "bar.txt"
//		val tstDataFile = folder.newFile(fileName)
//		val tstMdlFile = folder.newFile("test.mdl").toPath
//		val pwd = Paths.get("").toAbsolutePath()
//		val relative = pwd.relativize(tstDataFile.toPath)
		val basePath = Paths.get("").toAbsolutePath
		val mdlFile = Paths.get(basePath.toString, "tst.mdl")
		val dataFile = Paths.get("data.csv")
		val pharmFile = Paths.get(basePath.toString, "tst.xml")
		desBlk.createListDefn(dataObj.name, createAssignPair("file", createStringLiteral(dataFile.toString)),
			createEnumPair("inputFormat", "nonmemFormat")
		)
		
		val tdow = new TrialDesignDataObjectPrinter(mog, new StandardParameterWriter(null), false, mdlFile, pharmFile)
		val actual = tdow.writeTargetDataSet()
//		val expectedFName = relative.absUrlForRelativePath
		val expected = '''
			<ExternalDataSet toolName="NONMEM" oid="nm_ds">
				<DataSet xmlns="http://www.pharmml.org/pharmml/0.8/Dataset">
					<Definition>
					</Definition>
					<ExternalFile oid="id">
						<path>data.csv</path>
						<format>CSV</format>
						<delimiter>COMMA</delimiter>
					</ExternalFile>
				</DataSet>
			</ExternalDataSet>
		'''
		assertEquals("Output as expected", expected, actual.toString)
	}
	
	def String getAbsUrlForRelativePath(Path relPath){
		val absBase = Paths.get("").toAbsolutePath
		Paths.get(absBase.toString, relPath.toString).normalize.toString
	}

	@Test
	def void testWriteDesignParametersToRelativeDataAbsolute(){
		val mdl = createRoot
		val dataObj = mdl.createObject("foo", libDefns.getObjectDefinition("dataObj"))
		val mdlObj = mdl.createObject("foo2", libDefns.getObjectDefinition("mdlObj"))
		val mog = createMogDefn(mdl, dataObj, mdlObj)
		val desBlk = dataObj.createBlock(libDefns.getBlockDefinition(BlockDefinitionTable::DATA_SRC_BLK))
		val tstFile = Paths.get("bar.txt")
		desBlk.createListDefn(dataObj.name, createAssignPair("file", createStringLiteral(tstFile.toString)),
			createEnumPair("inputFormat", "nonmemFormat")
		)
		
		val tdow = new TrialDesignDataObjectPrinter(mog, new StandardParameterWriter(null), true, null, null)
		val actual = tdow.writeTargetDataSet()
		val expectedFName = tstFile.absUrlForRelativePath
		val expected = '''
			<ExternalDataSet toolName="NONMEM" oid="nm_ds">
				<DataSet xmlns="http://www.pharmml.org/pharmml/0.8/Dataset">
					<Definition>
					</Definition>
					<ExternalFile oid="id">
						<path>«expectedFName»</path>
						<format>CSV</format>
						<delimiter>COMMA</delimiter>
					</ExternalFile>
				</DataSet>
			</ExternalDataSet>
		'''
		assertEquals("Output as expected", expected, actual.toString)
	}

	@Test
	def void testWriteDesignParametersAbsoluteDataFileSet(){
		val mdl = createRoot
		val dataObj = mdl.createObject("foo", libDefns.getObjectDefinition("dataObj"))
		val mdlObj = mdl.createObject("foo2", libDefns.getObjectDefinition("mdlObj"))
		val mog = createMogDefn(mdl, dataObj, mdlObj)
		val desBlk = dataObj.createBlock(libDefns.getBlockDefinition(BlockDefinitionTable::DATA_SRC_BLK))
		val tstFile = Paths.get("bar.txt").toAbsolutePath
//		val pwd = Paths.get("").toAbsolutePath()
//		val relative = pwd.relativize(tstFile)
		desBlk.createListDefn(dataObj.name, createAssignPair("file", createStringLiteral(tstFile.toString)),
			createEnumPair("inputFormat", "nonmemFormat")
		)
		
		val tdow = new TrialDesignDataObjectPrinter(mog, new StandardParameterWriter(null))
		val actual = tdow.writeTargetDataSet()
		val expectedFName = tstFile.toString
		val expected = '''
			<ExternalDataSet toolName="NONMEM" oid="nm_ds">
				<DataSet xmlns="http://www.pharmml.org/pharmml/0.8/Dataset">
					<Definition>
					</Definition>
					<ExternalFile oid="id">
						<path>«expectedFName»</path>
						<format>CSV</format>
						<delimiter>COMMA</delimiter>
					</ExternalFile>
				</DataSet>
			</ExternalDataSet>
		'''
		assertEquals("Output as expected", expected, actual.toString)
	}


}