import numpy
import Image

def saveImage(array, name):
 	img = Image.fromarray(array)
	img.save(name)
	return


def getNHood(img, mask, i, j):
	n = img.shape[0] - 1
	m = img.shape[1] - 1
 	r = mask.shape[0]
	c = mask.shape[1]

	erosion = numpy.zeros((r, c), 'int')
	centerI = int(round(r/2.0))
	centerJ = int(round(c/2.0))
  
	k = 0
	for ii in range(i-centerI, i+(r-centerI)):
 		l = 0
		for jj in range(j-centerJ, j+(c-centerJ)):
  			if ii >= 0 and ii < n and j >= 0 and jj < m :
				erosion[k][l] = mask[k][l] * img[ii][jj]
		 	else:
				erosion[k][l] = 0
			l += 1
		k += 1
	return erosion

def getHistogram(img, l):
	n = img.shape[0] - 1
	m = img.shape[1] - 1
 	histogram = numpy.zeros((1, l), 'int')
 	for i in range(0,n):
  		for j in range(0,m):
   			histogram[img[i][j]] += 1
 		histogram = histogram / float(m * n)
	return histogram

def globalHistogramLinearization(img, l):
 	n = img.shape[0]
	m = img.shape[1]
 	image = numpy.zeros((n, m), 'int')
	s = numpy.zeros((1, l))
 	h = getHistogram(img, l)
 	div = float(m) * float(n);
 	k = (l - 1) / div;
  
	n -= 1;
	m -= 1;

 	for i in range(0,l-1):
  		sumH = 0.0
  		for j in range(0,i):
   			sumH += h[j]
  		s[i] = k * sumH;
  
 	for i in range(0,n):
  		for j in range(0,m):
   			image[i][j] = round(s(img[i][j]))
	return image

def localHistogramLinearization(img, l, nhoodI, nhoodJ):
 	n = img.shape[0]
	m = img.shape[1]
 	centerI = round(nhoodI/2.0)
 	centerJ = round(nhoodJ/2.0)
 	expImg = numpy.zeros((n + nhoodI - 1, m + nhoodJ - 1), 'int')
 	expImg[centerI:n + centerI - 1, centerJ: m + centerJ - 1] = img
 	histogram = numpy.zeros((1,l), 'int')
 	image = numpy.zeros((n,m), 'int')

	n -= 1
	n -= 1
	for i in range(centerI,n + centerI - 1):
  		for j in range(centerJ, m + centerJ - 1):
   			localImg = numpy.ones((nhoodI, nhoodJ), 'int')
   			localImg = getNHood(img, localImg, i, j)
   			localImg = globalHistogramLinearization(localImg, l)
   			image[i][j] = localImg[centerI][centerJ]
	return image

# open the images
carimg = Image.open('./car-ant.gif');
fig3img = Image.open('./Fig3.15(a).jpg');
l = 256;
nhoodI = nhoodJ = 3;

image = globalHistogramLinearization(carimg, l);
saveImage(image, 'result1.png');
#image = localHistogramLinearization(carimg, l,nhoodI, nhoodJ);



