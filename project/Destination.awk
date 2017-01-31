#Calculation throuput Destination link
BEGIN {

	timestart1 = 1.5;  timestart2 = 0.0;
	src1 = 0.0; dst1 = 4.0;
	src2 = 1.0; dst2 = 5.0;
	totalBitsRec1 = 0;
	totalBitsRec2 = 0; 
	
      }

{
Thr1 = "d1throughput.tr";
Thr2 = "d2throughput.tr";
if($1=="r" && $3 == 3 && $4 == 4 && $9 == src1 && $10 == dst1) 
{
	totalBitsRec1 += 8*$6;
	timestop1 = $2;
	through1 = totalBitsRec1/(timestop1-timestart1)
	print $2 " " through1 > Thr1
};

if($1=="r" && $3 == 3 && $4 == 5 && $9 == src2 && $10 == dst2)
{
	totalBitsRec2 += 8*$6;
	timestop2 = $2;
	through2 = totalBitsRec2/(timestop2-timestart2)
	print $2 " " through2 > Thr2
};
};


END{
print "Transmission: Flow 1 from S" src1+1 " -> D" dst1-3; 
print "Transmission: Flow 2 from S" src2+2 " -> D" dst2-2; 
};

