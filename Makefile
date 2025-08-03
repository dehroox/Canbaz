run:
	clang -Wall -luser32 -lgdi32 -lkernel32 -Wpedantic -Wextra -O0 -g src\main.c -o build\canbaz.tmp.exe && .\build\canbaz.tmp.exe

release:
	clang -Wall -luser32 -lgdi32 -lkernel32 -Wpedantic -Wextra -Ofast src\main.c -o build\canbaz.exe