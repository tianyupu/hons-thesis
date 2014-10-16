package weka.core;

import weka.core.TechnicalInformation.Field;
import weka.core.TechnicalInformation.Type;
import weka.core.neighboursearch.PerformanceStats;

public class SimilarityDistance
extends RankedDistance
implements TechnicalInformationHandler {

	/**
	 * 
	 */
	private static final long serialVersionUID = 4926634536990124857L;

	public SimilarityDistance() {
		super();
	}

	public SimilarityDistance(Instances data) {
		super(data);
	}

	public void initialize() {
		super.initialize();
		
		// normalise the rank weights 
		double sum = 0;
		for (int i=0; i<m_RankedMerits.length; i++) {
			sum += m_RankedMerits[i];
		}
		for (int i=0; i<m_RankWeights.length; i++) {
			m_RankWeights[i] = m_RankWeights[i] * m_RankedMerits[i] / sum;
		}
	}
	
	@Override
	public String getRevision() {
		// TODO Auto-generated method stub
		return null;
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
		int nneq = 0;
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
			if ((firstI < numAttributes) && !m_ActiveIndices[firstI]) {
				p1++;
				continue;
			}

			if (secondI == classIndex) {
				p2++;
				continue;
			}
			if ((secondI < numAttributes) && !m_ActiveIndices[secondI]) {
				p2++;
				continue;
			}

			double diff, weight;

			if (firstI == secondI) {
				weight = m_RankWeights[firstI];
				diff = weight * difference(firstI, first.valueSparse(p1), second.valueSparse(p2));
				p1++;
				p2++;
			} else if (firstI > secondI) {
				weight = m_RankWeights[secondI];
				diff = weight * difference(secondI, 0, second.valueSparse(p2));
				p2++;
			} else {
				weight = m_RankWeights[firstI];
				diff = weight * difference(firstI, first.valueSparse(p1), 0);
				p1++;
			}
			if (stats != null) {
				stats.incrCoordCount();
			}

			if (diff != 0) {
				nneq += 1;
			}
			distance = updateDistance(distance, diff);
			if (distance > cutOffValue) {
				return Double.POSITIVE_INFINITY;
			}
		}
		double rogerstDist = (2.0 * nneq) / (m_Data.numAttributes() + nneq);
		System.out.println(rogerstDist);
		return rogerstDist;
	}

	protected double difference(int index, double val1, double val2) {
		switch (m_Data.attribute(index).type()) {
		case Attribute.NOMINAL:
			return super.difference(index, val1, val2);

		case Attribute.NUMERIC:
			if (Utils.isMissingValue(val1) || Utils.isMissingValue(val2)) {
				if (Utils.isMissingValue(val1) && Utils.isMissingValue(val2)) {
					if (!m_DontNormalize) {
						return 1;
					} else {
						return (m_Ranges[index][R_MAX] - m_Ranges[index][R_MIN]) / m_Ranges[index][R_MAX];
					}
				} else {
					double diff;
					if (Utils.isMissingValue(val2)) {
						diff = 1.0;
					} else {
						diff = 1.0;
					}
					if (!m_DontNormalize && diff < 0.5) {
						diff = 1.0 - diff;
					} else if (m_DontNormalize) {
						if ((m_Ranges[index][R_MAX] - diff) > (diff - m_Ranges[index][R_MIN])) {
							return (m_Ranges[index][R_MAX] - diff) / m_Ranges[index][R_MIN];
						} else {
							return (diff - m_Ranges[index][R_MIN]) / diff;
						}
					}
					return diff;
				}
			} else {
				return (!m_DontNormalize) ? ((norm(val1, index) - norm(val2, index)) / norm(val1, index))
						: (val1 - val2) / val1;
			}

		default:
			return 0;
		}
	}
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
