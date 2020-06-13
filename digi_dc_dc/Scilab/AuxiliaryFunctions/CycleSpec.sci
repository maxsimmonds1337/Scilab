function Linespec=CycleSpec(n)
  // n : from 0 to N
  Linestyle =['-';'--';':';'-.']
  Linecolor = ['r';'g';'b';'c';'m';'k']
  Linemarker =['';'+';'o';'*';'.';'x';'s';'d';'^';'v';'>';'<';'p']
  i = modulo(n,size(Linecolor,'*'))+1
  j = modulo(floor(n/size(Linecolor,'*')),size(Linestyle,'*'))+1
  k = modulo(floor(n/size(Linecolor,'*')/size(Linestyle,'*')),size(Linemarker,'*'))+1
  Linespec = Linestyle(j)+Linecolor(i)+Linemarker(k)
endfunction
