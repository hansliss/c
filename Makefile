CFLAGS = -Wall
CC = cc
OBJ = .o

# lang must go first, as it creates lang.h
OBJS = \
	c${OBJ}\
	lang${OBJ}\
	scan${OBJ}

c.exe : c.c scan.c lang.c hc.h
	${CC} $(CFLAGS) -o c c.c scan.c lang.c -ll -lm

scan.c : scan.l lang.h hc.h
	flex scan.l
	mv lex.yy.c scan.c

lang.h : lang.c

lang.c : lang.y hc.h
	bison -y -v -d lang.y
	cp y.tab.c lang.c
	cp y.tab.h lang.h
	rm y.tab.*

clean :
	rm -f *${OBJ} lang.c lang.h scan.c c y.output 

