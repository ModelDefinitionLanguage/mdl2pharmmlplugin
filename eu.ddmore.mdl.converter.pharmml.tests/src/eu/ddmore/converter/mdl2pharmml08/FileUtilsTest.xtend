package eu.ddmore.converter.mdl2pharmml08

import java.nio.file.Path
import java.nio.file.Paths
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder

import static org.junit.Assert.assertEquals

class FileUtilsTest {

	@Rule
	public val TemporaryFolder folder = new TemporaryFolder() 
	
	private Path dataFile;
	private Path mdlFile;
	private Path pharmFile;
	
	@Before
	def void setUp() throws Exception {
		// relatve locations
		//  mdl
		// data
		// pharmml/dir1
		val mdlFolder = folder.newFolder("mdl")
		mdlFile = Paths.get(mdlFolder.getPath(), "tst.mdl")
//		Files.createFile(mdlFile)
		val dataFolder = folder.newFolder("data")
		dataFile = Paths.get(dataFolder.path, "data.csv")
//		Files.createFile(dataFile)
		val pharmFolder = folder.newFolder("pharmml", "dir1")
		pharmFile = Paths.get(pharmFolder.getPath(), "tst.xml");
//		Files.createFile(pharmFile);
	}

	@After
	def void tearDown() throws Exception {
		dataFile = null;
		mdlFile= null;
		pharmFile = null;
	}

	@Test
	def testGenerateRelativePath() {
		val mdlDataPath = Paths.get("..", "data", "data.csv");
		val actualResult = FileUtils.makeNewRelativeDataPath(mdlFile, mdlDataPath, pharmFile)
		assertEquals("../../data/data.csv", actualResult.toString);
	}


	@Test(expected=IllegalArgumentException)
	def void testGenerateFailAbsolutePath() {
		val mdlDataPath = Paths.get("..", "data", "foo.csv").toAbsolutePath;
		FileUtils.makeNewRelativeDataPath(mdlFile, mdlDataPath, pharmFile)
	}


}