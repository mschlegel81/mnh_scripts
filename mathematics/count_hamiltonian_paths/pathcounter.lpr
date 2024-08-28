{$mode objfpc}{$H+}
program pathcounter;
USES SysUtils;
VAR gridWidth:longint=4;
    gridHeight:longint=4;
    cellCount:longint;

CONST max_size=16;

TYPE
  T_boolList=array [0..max_size*max_size-1] of boolean;
  T_intList=array of longint;
  T_shortlist=record
    d:array[0..3] of word; fill:byte;
  end;

  { T_adjacency }

  T_adjacency=object
    neighborsOf:array [0..max_size*max_size-1] of T_shortlist;
    CONSTRUCTOR create;
    DESTRUCTOR destroy;
    FUNCTION dropNodeInitial(CONST nodeIndex:word):T_adjacency;
    FUNCTION dropNodeStep(CONST last,next:word):T_adjacency;
  end;

CONST BLANK_SHORTLIST : T_shortlist = (d:(65535,65535,65535,65535);fill:0);
FUNCTION withoutEdge(CONST s:T_shortlist; CONST toDrop:word):T_shortlist; inline;
  VAR i:longint;
  begin
    result.fill:=0;
    for i:=0 to s.fill-1 do if s.d[i]<>toDrop then begin
      result.d[result.fill]:=s.d[i];
      inc     (result.fill);
    end;
  end;

{ T_adjacency }

constructor T_adjacency.create;
  VAR i,j:longint;
  begin
    for j:=0 to gridHeight-1 do
    for i:=0 to gridWidth -1 do with neighborsOf[i+gridWidth*j] do begin
      fill:=0;
      if i>0 then begin
        d[fill]:=(i-1)+gridWidth*j;
        inc(fill);
      end;
      if i<gridWidth-1 then begin
        d[fill]:=(i+1)+gridWidth*j;
        inc(fill);
      end;
      if j>0 then begin
        d[fill]:=i+gridWidth*(j-1);
        inc(fill);
      end;
      if j<gridHeight-1 then begin
        d[fill]:=i+gridWidth*(j+1);
        inc(fill);
      end;
    end;
  end;

destructor T_adjacency.destroy;
  begin
  end;

function T_adjacency.dropNodeInitial(const nodeIndex: word): T_adjacency;
  VAR i:longint;
  begin
    Initialize(result);
    for i:=0 to cellCount-1 do result.neighborsOf[i]:=withoutEdge(neighborsOf[i],nodeIndex);
  end;

function T_adjacency.dropNodeStep(const last, next: word): T_adjacency;
  VAR i:longint;
  begin
    Initialize(result);
    for i:=0 to cellCount-1 do result.neighborsOf[i]:=withoutEdge(neighborsOf[i],next);
    result.neighborsOf[last]:=BLANK_SHORTLIST;
  end;

PROCEDURE findPathsFrom(CONST adjacency:T_adjacency; CONST last:word; CONST toBeVisited:T_boolList; VAR destCount:T_intList);
  VAR visitable:T_boolList;
      i,j:longint;
      next:word;
      N:T_shortlist;
      visitsOpen:boolean=false;
      sub_adjacency:T_adjacency;
  begin
    for i:=0 to cellCount-1 do visitsOpen:=visitsOpen or toBeVisited[i];
    if not(visitsOpen) then begin
      //Found path
      inc(destCount[last]);
      exit;
    end;

    for i:=0 to cellCount-1 do visitable[i]:=false;
    for j:=0 to cellCount-1 do with adjacency.neighborsOf[j] do for i:=0 to fill-1 do visitable[d[i]]:=true;
    for i:=0 to cellCount-1 do if toBeVisited[i] and not visitable[i]
      then exit; //Hamiltonian path no longer possible due to isolated node(s)

    N:=adjacency.neighborsOf[last];
    for i:=0 to N.fill-1 do begin
      next:=N.d[i];
      sub_adjacency:=adjacency.dropNodeStep(last,next);
      for j:=0 to cellCount-1 do visitable[j]:=toBeVisited[j] and (j<>next);
      findPathsFrom(sub_adjacency,next,visitable,destCount);
      sub_adjacency.destroy;
    end;
  end;


VAR adjacency:T_adjacency;
    symmetries:array of array of longint;
    toBeCalculated:T_intList;
    countMatrix:array of array of longint;
    startPointCounsidered:T_boolList;

PROCEDURE calcSymmetries;
  VAR i,k:longint;
      pending:T_boolList;
  begin

    if gridWidth=gridHeight
    then setLength(symmetries,8)
    else setLength(symmetries,4);
    for i:=0 to length(symmetries)-1 do setLength(symmetries[i],cellCount);

    for i:=0 to cellCount-1 do symmetries[0,i]:=i;
    for i:=0 to cellCount-1 do symmetries[1,i]:=(gridWidth-1-i mod gridWidth)+(i div gridWidth)*gridWidth;
    for k:=0 to 1 do
    for i:=0 to cellCount-1 do symmetries[k+2,i]:=symmetries[k,i] mod gridWidth+(gridHeight-1-symmetries[k,i] div gridWidth)*gridWidth;
    if gridWidth=gridHeight then
    for k:=0 to 3 do
    for i:=0 to cellCount-1 do symmetries[k+4,i]:=symmetries[k,i] div gridWidth+(symmetries[k,i] mod gridWidth)*gridWidth;

    //debug output:
    //writeln('Symmetries:');
    //for k:=0 to length(symmetries)-1 do begin
    //  write('  ');
    //  for i:=0 to w*h-1 do write(symmetries[k,i],', ');
    //  writeln;
    //end;

    setLength(toBeCalculated,0);
    for i:=0 to cellCount-1 do pending[i]:=true;
    for i:=0 to cellCount-1 do begin
      if pending[i] then begin
        setLength(toBeCalculated,length(toBeCalculated)+1);
        toBeCalculated[length(toBeCalculated)-1]:=i;
      end;
      for k:=0 to length(symmetries)-1 do pending[symmetries[k,i]]:=false;
    end;
  end;

PROCEDURE countPathWithSymmetries(CONST startIndex:longint);
  VAR A:T_adjacency;
      toBeVisited:T_boolList;
      destCount:T_intList;
      k,j:longint;
  begin
    A:=adjacency.dropNodeInitial(startIndex);

    for k:=0 to cellCount-1 do toBeVisited[k]:=k<>startIndex;
    setLength(destCount,cellCount);
    for k:=0 to cellCount-1 do destCount[k]:=0;

    findPathsFrom(A,startIndex,toBeVisited,destCount);

    for k:=0 to length(symmetries)-1 do
    if not startPointCounsidered[symmetries[k,startIndex]] then begin
      for j:=0 to cellCount-1 do
        countMatrix[symmetries[k,startIndex],symmetries[k,j]]+=destCount[j];
      startPointCounsidered[symmetries[k,startIndex]]:=true;
    end;

    setLength(destCount,0);
    A.destroy;
  end;

PROCEDURE logStartPointConsidered(CONST startIndex:longint);
  var k: Integer;
  begin
    for k:=0 to length(symmetries)-1 do
    startPointCounsidered[symmetries[k,startIndex]]:=true;
  end;

VAR i,j,k:longint;
    runMode:longint;
begin
  if ParamCount<2 then Halt(-1);
  gridWidth :=StrToIntDef(paramstr(1),-1);
  gridHeight:=StrToIntDef(paramstr(2),-1);
  if (gridWidth<=0) or (gridHeight<=0) then halt(-2);

  if paramCount=3
  then runMode:=strToIntDef(paramstr(3),-100)
  else runMode:=-100;

  cellCount:=gridWidth*gridHeight;
  adjacency.create;
  calcSymmetries;
  if runMode = -1 then begin
    for i in toBeCalculated do write(i,', ');
    halt(0);
  end;

  setLength(countMatrix,cellCount);
  for i:=0 to cellCount-1 do begin
    setLength(countMatrix[i],cellCount);
    for j:=0 to cellCount-1 do countMatrix[i,j]:=0;
  end;
  for i:=0 to cellCount-1 do startPointCounsidered[i]:=false;

  for k in toBeCalculated do
    if (runMode=-100) or (runMode=k)
    then countPathWithSymmetries(k)
    else logStartPointConsidered(k);

  for i:=0 to cellCount-1 do begin
    if i>0 then writeln;
    for j:=0 to cellCount-1 do write(countMatrix[i,j],', ');
  end;
  adjacency.destroy;
end.

