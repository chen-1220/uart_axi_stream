all:
	@vsim -do run.tcl

clean:
	@echo Cleaning...
	@del /q /f *.log *.wlf *.dat
	@for %%x in (*.*) do @if not "%%~xx"==".tcl" if not "%%x"=="Makefile" if not "%%x"=="makefile" del "%%x"
	@for /D %%d in (*) do @rd /s /q "%%d"

.PHONY: all clean
