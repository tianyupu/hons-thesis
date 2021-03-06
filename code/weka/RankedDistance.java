package weka.core;

import java.util.Collections;
import java.util.Enumeration;
import java.util.Vector;

import weka.attributeSelection.ASEvaluation;
import weka.attributeSelection.ASSearch;
import weka.attributeSelection.CorrelationAttributeEval;
import weka.attributeSelection.Ranker;
import weka.core.Instance;
import weka.core.Instances;
import weka.core.NormalizableDistance;
import weka.core.RevisionUtils;
import weka.core.neighboursearch.PerformanceStats;

/**
 * @author tian
 *
 */
public class RankedDistance
extends NormalizableDistance
implements Cloneable {

	private static final long serialVersionUID = 1068606253458807903L;

	/** Holds the ranked attributes */
	protected int[] m_RankedAttributes;

	/** Holds the "merit" of the ranked attributes. */
	protected double[] m_RankedMerits;

	/** Holds the weighting of the ranked attributes used by this distance function */
	protected double[] m_RankWeights;

	/** The actual ranker that performs attribute ranking */
	protected ASSearch m_AttributeRanker;

	/** The class that evaluates the goodness of the feature set. */
	protected ASEvaluation m_AttributeEvaluator;

	/** How much to update a weight if we find it important. */
	protected static double m_WeightUpdateFactor = 0.0001;

	/** The degree of the decay function. */
	protected double m_DecayDegree = 1;

	/** Whether or not to use a linear decay function. */
	protected boolean m_UseLinear = false;

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
	 * Sets the decay degree.
	 */
	protected void setDecayDegree(double decayDegree) {
		m_DecayDegree = decayDegree;
	}

	/**
	 * Gets the decay degree.
	 * @return the decay degree as a double
	 */
	protected double getDecayDegree() {
		return m_DecayDegree;
	}

	/**
	 * Sets whether or not to use a linear decay.
	 */
	protected void setLinearDecay(boolean useLinear) {
		m_UseLinear = useLinear;
	}

	/**
	 * Gets whether or not we are using a linear decay.
	 */
	protected boolean getLinearDecay() {
		return m_UseLinear;
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
			m_AttributeRanker.search(m_AttributeEvaluator, m_Data);

			double[][] tempRanked = ((Ranker) m_AttributeRanker).rankedAttributes();
			for (int i=0; i<tempRanked.length; i++) {
				int attributeIndex = (int) tempRanked[i][0];
				double attributeMerit = tempRanked[i][1];
				m_RankedAttributes[i] = attributeIndex;
				m_RankedMerits[attributeIndex] = attributeMerit;
				m_RankWeights[attributeIndex] = decayFunction(i);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * Given an attribute index, describes the decay of the ranking as it decreases.
	 */
	protected double decayFunction(int index) {
		if (m_UseLinear) {
			return m_Data.numAttributes() - index;
		} else {
			return 1.0 / Math.pow(index+1, m_DecayDegree);
		}
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
		return "Implementing a ranked distance function.\n\n"
				+ "The attributes are first ranked according to their level of"
				+ "correlation with the class, and then assigned weights which"
				+ "are used in the distane calculation.";
	}
	/**
	 * Returns an enumeration describing the available options.
	 * 
	 * @return an enumeration of all the available options.
	 */
	@Override
	public Enumeration<Option> listOptions() {
		Vector<Option> result = new Vector<Option>();

		result.addElement(new Option("\tSpecify the degree of the polynomial to decay with.",
				"P", 1, "-P"));

		result.addElement(new Option("\tUse a linear decay function.",
				"L", 0, "-L"));

		result.addAll(Collections.list(super.listOptions()));

		return result.elements();
	}

	/**
	 * Gets the current settings. Returns empty array.
	 * 
	 * @return an array of strings suitable for passing to setOptions()
	 */
	@Override
	public String[] getOptions() {
		Vector<String> result;

		result = new Vector<String>();

		result.add("-P");
		result.add(String.valueOf(getDecayDegree()));

		result.add("-L");
		result.add(String.valueOf(getLinearDecay()));

		Collections.addAll(result, super.getOptions());

		return result.toArray(new String[result.size()]);
	}

	/**
	 * Parses a given list of options.
	 * 
	 * @param options the list of options as an array of strings
	 * @throws Exception if an option is not supported
	 */
	@Override
	public void setOptions(String[] options) throws Exception {
		String tmpStr;

		tmpStr = Utils.getOption('P', options);
		if (tmpStr.length() != 0) {
			setDecayDegree(Double.parseDouble(tmpStr));
		} else {
			setDecayDegree(1);
		}

		setLinearDecay(Utils.getFlag('L', options));

		super.setOptions(options);
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
				p1++;
				p2++;
			} else if (firstI > secondI) {
				weight = m_RankWeights[secondI];
				diff = weight * difference(secondI, first, second, 0, second.valueSparse(p2));
				p2++;
			} else {
				weight = m_RankWeights[firstI];
				diff = weight * difference(firstI, first, second, first.valueSparse(p1), 0);
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
				//return m_RankWeights[index]; // return a small, non-zero distance
				return 0.5 * (1 + m_RankWeights[index]);
				// difference is not zero but class values are the same, so we should decrease the
				// weight of this attribute
			} else if (diff != 0 && first.classValue() == second.classValue()) {
				//return diff - m_RankWeights[index]
				return 0.5 / (1 + m_RankWeights[index]);
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
}