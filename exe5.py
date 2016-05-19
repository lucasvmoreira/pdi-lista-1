import numpy


def DTF(x):
	y = x
	n = x.shape[0]
	m = x.shape[1]
	for i in range(0,n):
		arange = numpy.arange(m)
		k = arange.reshape((m,1))
		M = numpy.exp(-2j*numpy.pi*k*arange / m)
		y[i] = numpy.dot(M,x[i])
	return x
		
