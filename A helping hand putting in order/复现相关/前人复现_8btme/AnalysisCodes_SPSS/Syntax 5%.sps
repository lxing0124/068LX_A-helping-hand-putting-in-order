* Encoding: UTF-8.

* MOTOR TASK
* Filtering out errors

USE ALL.
COMPUTE filter_$=(Accur = 1).
VARIABLE LABELS filter_$ 'Accur = 1 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.

* Finding the mean RT and SD

MEANS TABLES=RT BY Subject
  /CELLS=MEAN COUNT STDDEV.

* Filtering out RTs over 2 SDs (+ errors)
USE ALL.
COMPUTE filter_$=(Accur = 1 & RT < 750).
VARIABLE LABELS filter_$ 'Accur = 1 & RT < 750 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.


* Aggregating posture by finger

AGGREGATE
  /OUTFILE='D:\Reaserch\OSF\OSF 2\Original materials\Agg motor (posture by finger).sav'
  /BREAK=Posture Finger Subject
  /RT_mean=MEAN(RT).


* the RT of the fastest finger was subtracted from the RT of each other finger, obtaining an index of each finger relative speed (i.e., finger D).
* [[The finger D was then LATER subtracted from the average RT of each finger in each experimental mapping, resulting in a corrected finger RT.]]

DATASET ACTIVATE DataSet3.
COMPUTE D.index.Corrected=Down.Index - Fastest.
EXECUTE.

COMPUTE D.little.Corrected=Down.little - Fastest.
EXECUTE.

COMPUTE D.middle.Corrected=Down.middle - Fastest.
EXECUTE.

COMPUTE D.ring.Corrected=Down.ring - Fastest.
EXECUTE.

COMPUTE D.thumb.Corrected=Down.thumb - Fastest.
EXECUTE.

COMPUTE U.index.Corrected=Up.Index - Fastest.
EXECUTE.

COMPUTE U.little.Corrected=Up.little - Fastest.
EXECUTE.

COMPUTE U.middle.Corrected=Up.middle - Fastest.
EXECUTE.

COMPUTE U.ring.Corrected=Up.ring - Fastest.
EXECUTE.

COMPUTE U.thumb.Corrected=Up.thumb - Fastest.
EXECUTE.

* further correction was applied to avoid confounding effects of hand posture. [[Due to the faster performance in the prone posture,
for each participant the average RT of each finger in the prone posture was LATTER subtracted from its average RT in the supine posture
(i.e., posture D).]]

COMPUTE Corrected.Supine.Index=U.index.Corrected - D.index.Corrected.
EXECUTE.

COMPUTE Corrected.Supine.little=U.little.Corrected - D.little.Corrected.
EXECUTE.

COMPUTE Corrected.Supine.middle=U.middle.Corrected - D.middle.Corrected.
EXECUTE.

COMPUTE Corrected.Supine.ring=U.ring.Corrected - D.ring.Corrected.
EXECUTE.

COMPUTE Corrected.Supine.thumb=U.thumb.Corrected - D.thumb.Corrected.
EXECUTE.


* filtering out errors in the raw experimental data

DATASET ACTIVATE DataSet4.
USE ALL.
COMPUTE filter_$=(Accuracy = 1).
VARIABLE LABELS filter_$ 'Accuracy = 1 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.

* Finding the mean RT and SD

MEANS TABLES=RT BY Subject
  /CELLS=MEAN COUNT STDDEV.

* Filtering out RTs over 2 SDs (+ errors + analyzing only 5% )


USE ALL.
COMPUTE filter_$=(Accuracy = 1 & RT < 1500 & Trial < 11 & Subject < 306).
VARIABLE LABELS filter_$ 'Accuracy = 1 & RT < 1500 & Trial < 11 & Subject < 306 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.


* Aggregating mapping day by finger

AGGREGATE
  /OUTFILE='D:\Reaserch\OSF\OSF 2\Original materials\Agg experimental_5%.sav'
  /BREAK=Mapping GivenRespo Subject
  /RT_mean=MEAN(RT).

* The finger D was then NOW subtracted from the average RT of each finger in each experimental mapping, resulting in a corrected finger RT

DATASET ACTIVATE DataSet14.
COMPUTE A.thumb=A.b - D.thumb.Corrected.
EXECUTE.

COMPUTE A.index=A.h - D.index.Corrected.
EXECUTE.

COMPUTE A.middle=A.j - D.middle.Corrected.
EXECUTE.

COMPUTE A.ring=A.k - D.ring.Corrected.
EXECUTE.

COMPUTE A.little=A.l - D.little.Corrected.
EXECUTE.


COMPUTE B.thumb=B.b - D.thumb.Corrected.
EXECUTE.

COMPUTE B.index=B.h - D.index.Corrected.
EXECUTE.

COMPUTE B.middle=B.j - D.middle.Corrected.
EXECUTE.

COMPUTE B.ring=B.k - D.ring.Corrected.
EXECUTE.

COMPUTE B.little=B.l - D.little.Corrected.
EXECUTE.


COMPUTE C.thumb=C.b - U.thumb.Corrected.
EXECUTE.

COMPUTE C.index=C.h - U.index.Corrected.
EXECUTE.

COMPUTE C.middle=C.j - U.middle.Corrected.
EXECUTE.

COMPUTE C.ring=C.k - U.ring.Corrected.
EXECUTE.

COMPUTE C.little=C.l - U.little.Corrected.
EXECUTE.


COMPUTE D.thumb=D.b - U.thumb.Corrected.
EXECUTE.

COMPUTE D.index=D.h - U.index.Corrected.
EXECUTE.

COMPUTE D.middle=D.j - U.middle.Corrected.
EXECUTE.

COMPUTE D.ring=D.k - U.ring.Corrected.
EXECUTE.

COMPUTE D.little=D.l - U.little.Corrected.
EXECUTE.






COMPUTE E.thumb=E.b - D.thumb.Corrected.
EXECUTE.

COMPUTE E.index=E.h - D.index.Corrected.
EXECUTE.

COMPUTE E.middle=E.j - D.middle.Corrected.
EXECUTE.

COMPUTE E.ring=E.k - D.ring.Corrected.
EXECUTE.

COMPUTE E.little=E.l - D.little.Corrected.
EXECUTE.


COMPUTE F.thumb=F.b - D.thumb.Corrected.
EXECUTE.

COMPUTE F.index=F.h - D.index.Corrected.
EXECUTE.

COMPUTE F.middle=F.j - D.middle.Corrected.
EXECUTE.

COMPUTE F.ring=F.k - D.ring.Corrected.
EXECUTE.

COMPUTE F.little=F.l - D.little.Corrected.
EXECUTE.


COMPUTE G.thumb=G.b - U.thumb.Corrected.
EXECUTE.

COMPUTE G.index=G.h - U.index.Corrected.
EXECUTE.

COMPUTE G.middle=G.j - U.middle.Corrected.
EXECUTE.

COMPUTE G.ring=G.k - U.ring.Corrected.
EXECUTE.

COMPUTE G.little=G.l - U.little.Corrected.
EXECUTE.


COMPUTE H.thumb=H.b - U.thumb.Corrected.
EXECUTE.

COMPUTE H.index=H.h - U.index.Corrected.
EXECUTE.

COMPUTE H.middle=H.j - U.middle.Corrected.
EXECUTE.

COMPUTE H.ring=H.k - U.ring.Corrected.
EXECUTE.

COMPUTE H.little=H.l - U.little.Corrected.
EXECUTE.


* The posture D was then subtracted from the average RT of each finger in each experimental mapping of the supine
posture, resulting in a corrected supine finger RT.

DATASET ACTIVATE DataSet16.
COMPUTE Corr.C.thumb=C.thumb - Corrected.Supine.thumb.
EXECUTE.

COMPUTE Corr.C.index=C.index - Corrected.Supine.index.
EXECUTE.

COMPUTE Corr.C.middle=C.middle - Corrected.Supine.middle.
EXECUTE.

COMPUTE Corr.C.ring=C.ring - Corrected.Supine.ring.
EXECUTE.

COMPUTE Corr.C.little=C.little - Corrected.Supine.little.
EXECUTE.


COMPUTE Corr.D.thumb=C.thumb - Corrected.Supine.thumb.
EXECUTE.

COMPUTE Corr.D.index=C.index - Corrected.Supine.index.
EXECUTE.

COMPUTE Corr.D.middle=C.middle - Corrected.Supine.middle.
EXECUTE.

COMPUTE Corr.D.ring=C.ring - Corrected.Supine.ring.
EXECUTE.

COMPUTE Corr.D.little=C.little - Corrected.Supine.little.
EXECUTE.



COMPUTE Corr.G.thumb=C.thumb - Corrected.Supine.thumb.
EXECUTE.

COMPUTE Corr.G.index=C.index - Corrected.Supine.index.
EXECUTE.

COMPUTE Corr.G.middle=C.middle - Corrected.Supine.middle.
EXECUTE.

COMPUTE Corr.G.ring=C.ring - Corrected.Supine.ring.
EXECUTE.

COMPUTE Corr.G.little=C.little - Corrected.Supine.little.
EXECUTE.


COMPUTE Corr.H.thumb=C.thumb - Corrected.Supine.thumb.
EXECUTE.

COMPUTE Corr.H.index=C.index - Corrected.Supine.index.
EXECUTE.

COMPUTE Corr.H.middle=C.middle - Corrected.Supine.middle.
EXECUTE.

COMPUTE Corr.H.ring=C.ring - Corrected.Supine.ring.
EXECUTE.

COMPUTE Corr.H.little=C.little - Corrected.Supine.little.
EXECUTE.


* calculation the corrected RTs of each of the 8 experimental conditions

COMPUTE A=MEAN(A.thumb, A.index, A.middle, A.ring, A.little).
EXECUTE.

COMPUTE B=MEAN(B.thumb, B.index, B.middle, B.ring, B.little).
EXECUTE.

COMPUTE C=MEAN(Corr.C.thumb, Corr.C.index, Corr.C.middle, Corr.C.ring, Corr.C.little).
EXECUTE.

COMPUTE D=MEAN(Corr.D.thumb, Corr.D.index, Corr.D.middle, Corr.D.ring, Corr.D.little).
EXECUTE.

COMPUTE E=MEAN(E.thumb, E.index, E.middle, E.ring, A.little).
EXECUTE.

COMPUTE F=MEAN(F.thumb, F.index, F.middle, F.ring, F.little).
EXECUTE.

COMPUTE G=MEAN(Corr.G.thumb, Corr.G.index, Corr.G.middle, Corr.G.ring, Corr.G.little).
EXECUTE.

COMPUTE H=MEAN(Corr.H.thumb, Corr.H.index, Corr.H.middle, Corr.H.ring, Corr.H.little).
EXECUTE.


* the focal ANOVA

GLM A B C D E F G H
  /WSFACTOR=Language 2 Polynomial Posture 2 Polynomial Direction 2 Polynomial 
  /METHOD=SSTYPE(3)
  /EMMEANS=TABLES(OVERALL) 
  /EMMEANS=TABLES(Language) 
  /EMMEANS=TABLES(Posture) 
  /EMMEANS=TABLES(Direction) 
  /EMMEANS=TABLES(Language*Posture) 
  /EMMEANS=TABLES(Language*Direction) 
  /EMMEANS=TABLES(Posture*Direction) 
  /EMMEANS=TABLES(Language*Posture*Direction) 
  /PRINT=DESCRIPTIVE ETASQ 
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=Language Posture Direction Language*Posture Language*Direction Posture*Direction 
    Language*Posture*Direction.



