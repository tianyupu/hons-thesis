/**
 * 
 */
package weka.core;

import weka.attributeSelection.ASEvaluation;
import weka.attributeSelection.ASSearch;
import weka.attributeSelection.CorrelationAttributeEval;
import weka.attributeSelection.InfoGainAttributeEval;
import weka.attributeSelection.Ranker;
import weka.core.Instance;
import weka.core.Instances;
import weka.core.NormalizableDistance;
import weka.core.RevisionUtils;
import weka.core.TechnicalInformation;
import weka.core.TechnicalInformationHandler;
import weka.core.TechnicalInformation.Field;
import weka.core.TechnicalInformation.Type;
import weka.core.neighboursearch.PerformanceStats;

/**
 * @author tian
 *
 */
public class RankedDistance
extends NormalizableDistance
implements TechnicalInformationHandler {

	private static final long serialVersionUID = 1068606253458807903L;

	/** Holds the ranked attributes */
	private int[] m_RankedAttributes;

	/** Holds the "merit" of the ranked attributes. */
	private double[] m_RankedMerits;
	
	/** Holds the weighting of the ranked attributes used by this distance function */
	private double[] m_RankWeights;

	/** The actual ranker that performs attribute ranking */
	private ASSearch m_AttributeRanker;

	/** The class that evaluates the goodness of the feature set. */
	protected ASEvaluation m_AttributeEvaluator;
	
	/** How much to update a weight if we find it important. */
	protected static double m_WeightUpdateFactor = 0.001;

	/**
	 * 
	 */
	public RankedDistance() {
		super();
	}

	/**
	 * @param data
	 * @throws Exception 
	 */
	public RankedDistance(Instances data) {
		super(data);
	}

	/**
	 * initializes the ranges and the attributes being used.
	 */
	protected void initialize() {
		super.initialize();

		m_AttributeRanker = new Ranker();
		m_AttributeEvaluator = new CorrelationAttributeEval();
		m_RankedAttributes = new int[m_Data.numAttributes()];
		m_RankedMerits = new double[m_Data.numAttributes()];
		m_RankWeights = new double[m_Data.numAttributes()];
		
		try {
			m_AttributeEvaluator.buildEvaluator(m_Data);
			//m_RankedAttributes = m_AttributeRanker.search(m_AttributeEvaluator, m_Data);
			m_AttributeRanker.search(m_AttributeEvaluator, m_Data);
			
			double[][] tempRanked = ((Ranker) m_AttributeRanker).rankedAttributes();
			for (int i=0; i<tempRanked.length; i++) {
				int attributeIndex = (int) tempRanked[i][0];
				double attributeMerit = tempRanked[i][1];
				m_RankedAttributes[i] = attributeIndex;
				m_RankedMerits[attributeIndex] = attributeMerit;
				m_RankWeights[attributeIndex] = 1.0 / Math.pow(i+1, 2.0/3.0);
			}
			
		} catch (Exception e) {
			e.printStackTrace();
		}
/*
		int rankedAttributeIndex;

		for (int i=0; i<m_RankWeights.length; i++) {
			if (i < m_RankedAttributes.length) {
				rankedAttributeIndex = m_RankedAttributes[i]; // the index of a ranked attribute
				// if m_RankedAttributes = [13, 23 ...], then m_RankWeights = [...0...1] at the 13th and 23rd indices
				m_RankWeights[rankedAttributeIndex] = 1.0 / Math.pow(i+1, 2.0/3.0);
				//m_RankWeights[rankedAttributeIndex] = m_RankedMerits[rankedAttributeIndex];
			} else {
				m_RankWeights[i] = 0;
			}
		}
*/
	}

	/* (non-Javadoc)
	 * @see weka.core.RevisionHandler#getRevision()
	 */
	@Override
	public String getRevision() {
		return RevisionUtils.extract("$Revision: 1 $");
	}

	/* (non-Javadoc)
	 * @see weka.core.NormalizableDistance#globalInfo()
	 */
	@Override
	public String globalInfo() {
		return 
				"Implementing Euclidean distance (or similarity) function.\n\n"
				+ "One object defines not one distance but the data model in which "
				+ "the distances between objects of that data model can be computed.\n\n"
				+ "Attention: For efficiency reasons the use of consistency checks "
				+ "(like are the data models of the two instances exactly the same), "
				+ "is low.\n\n"
				+ "For more information, see:\n\n"
				+ getTechnicalInformation().toString();
	}

	/**
	 * Calculates the distance between two instances. Offers speed up (if the
	 * distance function class in use supports it) in nearest neighbour search by
	 * taking into account the cutOff or maximum distance. Depending on the
	 * distance function class, post processing of the distances by
	 * postProcessDistances(double []) may be required if this function is used.
	 * 
	 * @param first the first instance
	 * @param second the second instance
	 * @param cutOffValue If the distance being calculated becomes larger than
	 *          cutOffValue then the rest of the calculation is discarded.
	 * @param stats the performance stats object
	 * @return the distance between the two given instances or
	 *         Double.POSITIVE_INFINITY if the distance being calculated becomes
	 *         larger than cutOffValue.
	 */
	@Override
	public double distance(Instance first, Instance second, double cutOffValue,
			PerformanceStats stats) {
		double distance = 0;
		int firstI, secondI;
		int firstNumValues = first.numValues();
		int secondNumValues = second.numValues();
		int numAttributes = m_Data.numAttributes();
		int classIndex = m_Data.classIndex();

		validate();

		for (int p1 = 0, p2 = 0; p1 < firstNumValues || p2 < secondNumValues;) {
			if (p1 >= firstNumValues) {
				firstI = numAttributes;
			} else {
				firstI = first.index(p1);
			}

			if (p2 >= secondNumValues) {
				secondI = numAttributes;
			} else {
				secondI = second.index(p2);
			}

			if (firstI == classIndex) {
				p1++;
				continue;
			}
			if ((firstI < numAttributes) && m_RankWeights[firstI] == 0) {
				p1++;
				continue;
			}

			if (secondI == classIndex) {
				p2++;
				continue;
			}
			if ((secondI < numAttributes) && m_RankWeights[secondI] == 0) {
				p2++;
				continue;
			}

			double diff;
			double weight;

			if (firstI == secondI) {
				weight = m_RankWeights[firstI];
				diff = weight * difference(firstI, first, second, first.valueSparse(p1), second.valueSparse(p2));
				//diff = weight * difference(firstI, first.valueSparse(p1), second.valueSparse(p2));
				p1++;
				p2++;
			} else if (firstI > secondI) {
				weight = m_RankWeights[secondI];
				diff = weight * difference(secondI, first, second, 0, second.valueSparse(p2));
				//diff = weight * difference(secondI, 0, second.valueSparse(p2));
				p2++;
			} else {
				weight = m_RankWeights[firstI];
				diff = weight * difference(firstI, first, second, first.valueSparse(p1), 0);
				//diff = weight * difference(firstI, first.valueSparse(p1), 0);
				p1++;
			}
			if (stats != null) {
				stats.incrCoordCount();
			}
			
			distance = updateDistance(distance, diff);
			if (distance > cutOffValue) {
				return Double.POSITIVE_INFINITY;
			}
		}

		return distance;
	}

	protected double difference(int index, Instance first, Instance second, double val1, double val2) {
		double diff = super.difference(index, val1, val2);
		
		switch (m_Data.attribute(index).type()) {
		case Attribute.NOMINAL:
			// difference between attribute values is 0 but the classes are different
			// so we should increase the importance of this attribute but also
			// return a non-zero difference
			if (diff == 0 && first.classValue() != second.classValue()) {
				//m_RankWeights[index] *= (1 + m_WeightUpdateFactor); // increase weighting of attr
				return m_RankWeights[index]; // return a small, non-zero distance
			// difference is not zero but class values are the same, so we should decrease the
			// weight of this attribute
			} else if (diff != 0 && first.classValue() == second.classValue()) {
				return diff - m_RankWeights[index];
			}
			return diff;
			
		case Attribute.NUMERIC:
			 return diff;
		
		default:
			 return 0;
		}
	}
	/* (non-Javadoc)
	 * @see weka.core.NormalizableDistance#updateDistance(double, double)
	 */
	@Override
	protected double updateDistance(double currDist, double diff) {
		double result;

		result = currDist;
		result += Math.abs(diff);

		return result;
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		int[] testArray = new int[10];
		for (int i=0; i<5; i++) {
			testArray[i] = i+1;
		}
		System.out.println(testArray.length);
	}

	@Override
	public TechnicalInformation getTechnicalInformation() {
		TechnicalInformation result;

		result = new TechnicalInformation(Type.MISC);
		result.setValue(Field.AUTHOR, "Wikipedia");
		result.setValue(Field.TITLE, "Euclidean distance");
		result.setValue(Field.URL, "http://en.wikipedia.org/wiki/Euclidean_distance");

		return result;
	}

}
