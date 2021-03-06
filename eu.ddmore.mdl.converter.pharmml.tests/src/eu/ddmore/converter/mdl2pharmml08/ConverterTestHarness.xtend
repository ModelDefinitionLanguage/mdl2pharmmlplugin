package eu.ddmore.converter.mdl2pharmml08

import eu.ddmore.mdl.mdl.Mcl
import eu.ddmore.mdl.provider.MogDefinitionProvider
import foundation.ddmore.pharmml08.PharmMlFactory
import java.io.BufferedWriter
import java.io.FileInputStream
import java.io.FileReader
import java.io.FileWriter
import java.io.InputStream

import static org.junit.Assert.*

class ConverterTestHarness {

	extension Mdl2Pharmml mpc = new Mdl2Pharmml
	extension MogDefinitionProvider mdp = new MogDefinitionProvider


	def readFile(String fileName){
		var FileReader in = null
		try{
			in = new FileReader(fileName)
			var char[] buf = newCharArrayOfSize(2048)
			var mdlStr = ""
			var c = 0
			while((c = in.read(buf, 0, buf.length)) != -1){
				mdlStr = mdlStr.concat(new String(buf, 0, c))
			}
			mdlStr
		}
		finally{
			in?.close
		}
	}
	
	
	def void convertTo(Mcl mcl, String destFile){
		val mogObj = mcl.firstMogObj
		val output = mogObj.convertToPharmML
		var out = new BufferedWriter(new FileWriter(destFile))
		out.write(output.toString, 0, output.length)
		out.close
	}
	
	def void assertIsValid(String destFile){
		var InputStream inputStream = null
		try{
			inputStream = new FileInputStream(destFile)
	    	val libPharmML = PharmMlFactory.getInstance().createLibPharmML();
			val res = libPharmML.createDomFromResource(inputStream);
			val rpt = res.creationReport;
			val iter = rpt.errorIterator
			while(iter.hasNext){
				val error = iter.next
				System.err.println(error.errorMsg)
			}
			assertTrue("PharmML is valid: " + destFile, rpt.isValid())
		}
		finally{
			inputStream?.close();
		}
	}
	
}