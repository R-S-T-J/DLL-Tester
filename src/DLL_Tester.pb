EnableExplicit

#Library = 0
#Results = 0

Define InputFile$
Define InputPattern$ = "DLL (*.dll)|*.dll|all files (*.*)|*.*"

Define OutputFile$
Define OutputPattern$ = "Text (*.txt)|*.txt|all files (*.*)|*.*"


Global WindowTitle$
Global xsystem$

Global enable_run = #False
Global enable_save = #False


CompilerSelect  #PB_Compiler_Processor
	CompilerCase  #PB_Processor_x86  
		xsystem$="x86"
	CompilerCase #PB_Processor_x64 
		xsystem$="x64"
CompilerEndSelect

WindowTitle$ = "DLL-Tester for " + xsystem$ + " files"

XIncludeFile "DLL_Tester_form.pbf"

Declare ReadDLL()

OpenWindow_Main()
Define event

Repeat
	event = WaitWindowEvent()
	Select event
		Case #PB_Event_CloseWindow
			End
			
		Case #PB_Event_Gadget
			Select EventGadget()
				Case #Button_open
					InputFile$=OpenFileRequester("Choose DLL", "", InputPattern$, 0)
					If OpenLibrary(#Library, InputFile$)
						ExamineLibraryFunctions(#Library)
						enable_run = #True
					Else
						MessageRequester("Info", InputFile$ + " cannot be opened" + Chr(13) + Chr(13) + "maybe it is not a " + xsystem$ + " DLL file", #PB_MessageRequester_Info | #PB_MessageRequester_Ok)
						enable_run = #False
					EndIf
					
				Case #Checkbox_save
					If GetGadgetState(#Checkbox_save) = #PB_Checkbox_Checked
						OutputFile$=SaveFileRequester("Choose Output File", "output" + "_" + xsystem$ + ".txt", OutputPattern$, 0)
						If OpenFile(#Results, OutputFile$)
							enable_save = #True
						Else
							MessageRequester("Info", "cannot write " + OutputFile$ , #PB_MessageRequester_Info | #PB_MessageRequester_Ok)
							enable_save = #False
						EndIf
					Else
						enable_save = #False
					EndIf
					
					
				Case #Button_scan
					If enable_run = #True
						
						ReadDLL()
						
						If enable_save = #True
							CloseFile(#Results)
						EndIf
						
						CloseLibrary(#Library)
					EndIf
					
			EndSelect
	EndSelect
ForEver

Procedure ReadDLL()
	Define LastResult$ = "x"
	Define Result$ = "o"
	Define repetitions.i
	Define counter.i
	
	ClearGadgetItems(#ListView)
	
	Repeat
		NextLibraryFunction()
		Result$ = LibraryFunctionName()
		
		If LastResult$ = Result$
			repetitions + 1
			If repetitions = 65535
				AddGadgetItem(#ListView, -1, "------------------------------")
				AddGadgetItem(#ListView, -1, Str(counter) + " functions found")
				
				Break
			EndIf 
		EndIf
		
		If Result$ <> ""
			AddGadgetItem(#ListView, -1, Result$)
			counter + 1
			If enable_save = #True
				WriteStringN(#Results, Result$)
			EndIf
		EndIf
		
		LastResult$ = Result$
		
	ForEver
EndProcedure
