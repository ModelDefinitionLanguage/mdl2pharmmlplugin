package eu.ddmore.converter.mdl2pharmml08

import java.nio.file.Path
import java.nio.file.Paths
import org.junit.After
import org.junit.Before
import org.junit.Test

import static org.junit.Assert.assertEquals

class FileUtilsWithDotDirTest {

	private Path dataFile;
	private Path mdlFile;
	private Path pharmFile;
	
	@Before
	def void setUp() throws Exception {
		// relatve locations
		//  mdl
		// data
		// pharmml/dir1
		val basePath = Paths.get("").toAbsolutePath
		val mdlFolder = Paths.get(basePath.toString, "mdl")
		mdlFile = Paths.get(mdlFolder.toString, "tst.mdl")
//		Files.createFile(mdlFile)
		val dataFolder = Paths.get("data")
		dataFile = Paths.get(dataFolder.toString, "data.csv")
//		Files.createFile(dataFile)
		val pharmFolder = Paths.get(basePath.toString, "pharmml", "dir1")
		pharmFile = Paths.get(pharmFolder.toString, "tst.xml");
//		Files.createFile(pharmFile);
	}

	@After
	def void tearDown() throws Exception {
		dataFile = null;
		mdlFile= null;
		pharmFile = null;
	}

	@Test
	def testMakeRelativePath() {
		val mdlDataPath = Paths.get("..", "data", "data.csv");
		val actualResult = FileUtils.makeNewRelativeDataPath(mdlFile, mdlDataPath, pharmFile)
		assertEquals("../../data/data.csv", actualResult.toString);
	}

	@Test(expected=IllegalArgumentException)
	def void testMakeRelPathFailAbsolutePath() {
		val mdlDataPath = Paths.get("..", "data", "foo.csv").toAbsolutePath;
		FileUtils.makeNewRelativeDataPath(mdlFile, mdlDataPath, pharmFile)
	}

	@Test
	def testGeneratePathWithAbsDataNoRef() {
		val mdlDataPath = dataFile;
		val actualResult = FileUtils.generateDataPath(true, null, mdlDataPath, null)
		assertEquals(dataFile.toAbsolutePath.toString, actualResult.toString);
	}

	@Test
	def testGeneratePathWithAbsDataRefAndAbsFlag() {
		val mdlDataPath = Paths.get("..", "data", "data.csv");
		val actualResult = FileUtils.generateDataPath(true, mdlFile, mdlDataPath, pharmFile)
		assertEquals(dataFile.toAbsolutePath.toString, actualResult.toString);
	}

	@Test
	def testGeneratePathWithAbsDataNoAbsFlag() {
		val mdlDataPath = dataFile.toAbsolutePath
		val actualResult = FileUtils.generateDataPath(false, mdlFile, mdlDataPath, pharmFile)
		assertEquals(dataFile.toAbsolutePath.toString, actualResult.toString);
	}

	@Test
	def testGenerateAbsFromRelPathWithRef() {
		val mdlDataPath = Paths.get("..", "data", "data.csv");
		val actualResult = FileUtils.generateDataPath(true, mdlFile, mdlDataPath, pharmFile)
		assertEquals(dataFile.toAbsolutePath.toString, actualResult.toString);
	}

	@Test
	def testGenerateAbsFromRelPathNoRef() {
		val mdlDataPath = Paths.get("..", "data", "data.csv");
		val actualResult = FileUtils.generateDataPath(true, null, mdlDataPath, null)
		assertEquals(Paths.get(Paths.get("").toAbsolutePath.toString, mdlDataPath.toString).toString, actualResult.toString);
	}

	@Test
	def testGenerateRelFromRelPathWithRef() {
		val mdlDataPath = Paths.get("..", "data", "data.csv");
		val actualResult = FileUtils.generateDataPath(false, mdlFile, mdlDataPath, pharmFile)
		assertEquals("../../data/data.csv", actualResult.toString);
	}

	@Test
	def testGenerateRelFromRelPathNoRef() {
		val mdlDataPath = Paths.get("..", "data", "data.csv");
		val actualResult = FileUtils.generateDataPath(false, null, mdlDataPath, null)
		assertEquals("../data/data.csv", actualResult.toString);
	}


}