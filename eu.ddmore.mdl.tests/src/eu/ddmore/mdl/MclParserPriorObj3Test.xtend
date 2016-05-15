package eu.ddmore.mdl

import com.google.inject.Inject
import eu.ddmore.mdl.mdl.Mcl
import java.util.Deque
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import eu.ddmore.mdl.utils.BlockUtils

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(MdlAndLibInjectorProvider))
class MclParserPriorObj3Test {
	@Inject extension MdlTestHelper<Mcl>
	@Inject extension ValidationTestHelper

	extension BlockUtils bu = new BlockUtils
	
	val static CODE_SNIPPET = '''
testprior = priorObj{
	PRIOR_PARAMETERS{
		MU_V = 0.3
		VAR_V = 0.3
		# What is meant here
		a_OMEGA_V=0.3
		b_OMEGA_V=0.3
		a_OMEGA_k=0.3
		b_OMEGA_k=0.3
		a_OMEGA_SIGMA2_RES=0.3
		b_OMEGA_SIGMA2_RES=0.3
	}

	NON_CANONICAL_DISTRIBUTION{
		PRIOR_SOURCE{
			data : { file="simple3_prior.csv", inputFormat is RList,
						format=[{element="bins_k", type is vector},
								{element="p_k_v", type is matrix},
								{element="data_SIGMA2_RES", type is vector},
								{element="p_SIGMA2_RES", type is vector}	] }    #the file structure has to be decided
		}

		INPUT_PRIOR_DATA{
			bins_k_v = readMatrix(src=data, element="bins_k_v")
			p_k = readVector(src=data, element="p_k")
			p_SIGMA2_RES = readVector(src=data, element="p_SIGMA2_RES")
			data_SIGMA2_RES = readVector(src=data, element="data_SIGMA2_RES")
		}
	}

	PRIOR_VARIABLE_DEFINITION{
		 lnMU_V = MU_V
		 mp ~ MultiNonParametric(bins=bins_k_v, probability=p_k)
		 POP_K = mp[0]
		 POP_V = mp[1]
		invPOP_SIGMA2_RES ~ Empirical(data=data_SIGMA2_RES, probability=p_SIGMA2_RES) 

		invOMEGA_V ~ Gamma1(shape=a_OMEGA_V, scale=b_OMEGA_V)
		invOMEGA_k ~ Gamma1(shape=a_OMEGA_k, scale=b_OMEGA_k)
		invOMEGA_SIGMA_RES ~ Gamma1(shape=a_OMEGA_SIGMA2_RES, scale=b_OMEGA_SIGMA2_RES)
	}
	

}
		'''
	
	@Test
	def void testParsing(){
		CODE_SNIPPET.parse.assertNoErrors
		
	}
	
	@Test
	def void testBlocks(){
		val mcl = CODE_SNIPPET.parse
		val Deque<String> expectedBlks = newLinkedList("PRIOR_PARAMETERS", "NON_CANONICAL_DISTRIBUTION", "PRIOR_VARIABLE_DEFINITION");
		for(blk : mcl.objects.last.blocks){
			Assert::assertEquals(expectedBlks.pop, blk.identifier)
		}
	}

	
}