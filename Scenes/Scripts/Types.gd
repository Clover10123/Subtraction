enum Element {A, E, W, F}


func compatible(e, f):
	print("Compatible: " + str(e) + ", " + str(f) + "")
	return (e+f) == 3 || e == f;

