'**************************************************
'* demo7.bmx									  *
'* � 2004 by N-Software.info, Nicolas De Jaeghere *
'**************************************************

Strict

Local age:Int
Local ageString:String

ageString = Input("Age ")

age = Int(ageString)

If age = 18 Then
	
	Print "Age = 18"
Else If age > 18 Then
	
	Print "Age > 18"
Else If age < 18 Then
	
	Print "Age < 18"
End If

WaitKey

End