program heptagon;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes,
  SysUtils, vectorTypes
  { you can add units after this };

CONST COARSE_GRID_GRANULARITY=128;
      FINE_GRID_GRANULARITY  =512;

FUNCTION errorVectorAt(CONST alpha:double; CONST phi:Vector4):Vector3;
  VAR d:Vector3=(1,0,0);
      d5:Vector3;
      a:Matrix3x3=(1,0,0,0,1,0,0,0,1);
      rotZ:Matrix3x3;
  begin
    rotZ:=rz(alpha);
    a:=rotZ;              d +=Vector3(a);
    a:=a*rx(phi[0])*rotZ; d +=Vector3(a);
    a:=a*rx(phi[1])*rotZ; d +=Vector3(a);
    a:=a*rx(phi[2])*rotZ; d +=Vector3(a);
    a:=a*rx(phi[3])*rotZ; d5:=Vector3(a); d+=d5;
    result[0]:=sqrt(d[0]*d[0]+d[1]*d[1]+d[2]*d[2]);
    result[1]:=d[0]/result[0]+rotZ[0];
    result[2]:=d*d5/result[0]+rotZ[0];
    result[0]-=1;
  end;

FUNCTION simplexContractionCenter(CONST S:SampledSimplex):Vector4;
  PROCEDURE fitParameters(CONST S:SampledSimplex; CONST k:longint; OUT linearTerm:Vector4; OUT offset:double);
    FUNCTION elementwiseSqr(CONST v:Vector4): Vector4; inline;
      begin
        result[0]:=v[0]*v[0];
        result[1]:=v[1]*v[1];
        result[2]:=v[2]*v[2];
        result[3]:=v[3]*v[3];
      end;
    VAR mPhi:Vector4;
        mErr:double;

        phiErr:Vector4=(0,0,0,0);
        phi2  :Vector4=(0,0,0,0);
        i:longint;

        normalizationFactor:double;
    begin
      mPhi:=vector4Of(0,0,0,0);
      mErr:=0;
      for i:=0 to length(S)-1 do begin
        mPhi+=S[i].phi;
        mErr+=S[i].err[k];
      end;
      mPhi*=(1/length(S));
      mErr*=(1/length(S));
      for i:=0 to length(S)-1 do begin
        phiErr+=              (S[i].phi-mPhi)*(S[i].err[k]-mErr);
        phi2  +=elementwiseSqr(S[i].phi-mPhi)                   ;
      end;
      linearTerm[0]:=phiErr[0]/phi2[0]; normalizationFactor:=sqr(linearTerm[0]);
      linearTerm[1]:=phiErr[1]/phi2[1]; normalizationFactor+=sqr(linearTerm[1]);
      linearTerm[2]:=phiErr[2]/phi2[2]; normalizationFactor+=sqr(linearTerm[2]);
      linearTerm[3]:=phiErr[3]/phi2[3]; normalizationFactor+=sqr(linearTerm[3]);
      if normalizationFactor>1E-10
      then normalizationFactor:=1/sqrt(normalizationFactor)
      else normalizationFactor:=1;

      offset:=(mErr-linearTerm*mPhi)* normalizationFactor;
      linearTerm                    *=normalizationFactor;
    end;

  FUNCTION contractionCenter(CONST p,q,r,n:Vector4; CONST a,b,c:double):Vector4;
    VAR work:array[0..3,0..4] of double;
    PROCEDURE doPivot(CONST colIdx:longint);
      VAR k:longint=0;
          i:longint;
          tmp:double;
      begin
        k:=colIdx;
        for i:=colIdx+1 to 3 do if abs(work[i,colIdx])>abs(work[k,colIdx]) then k:=i;
        if k<>colIdx then for i:=0 to 4 do begin
          tmp           :=work[colIdx,i];
          work[colIdx,i]:=work[k     ,i];
          work[k     ,i]:=tmp;
        end;
      end;

    VAR i,j,k:longint;
        factor:double;
        tmp:Vector4;
        offset:Vector4;
    begin
      for i:=0 to 3 do work[0,i]:=p[i]; work[0,4]:=a;
      for i:=0 to 3 do work[1,i]:=q[i]; work[1,4]:=b;
      for i:=0 to 3 do work[2,i]:=r[i]; work[2,4]:=c;
      for i:=0 to 3 do work[3,i]:=n[i]; work[3,4]:=0;
      //Gauss Jordan:-----------------------------------
      for i:=0 to 3 do begin
        doPivot(i);
        factor:=1/work[i,i];
        for j:=0 to 4 do work[i,j]*=factor;
        for k:=0 to 3 do if k<>i then begin
          factor:=work[k,i];
          for j:=0 to 4 do work[k,j]-=factor*work[i,j];
        end;
      end;
      //-----------------------------------:Gauss Jordan
      for i:=0 to 3 do offset[i]:=work[i,4];
      tmp:=vector4Of(0,0,0,0);
      for k:=0 to length(S)-1 do tmp+=S[k].phi;
      tmp:=tmp*(1/length(s))-offset;
      factor:=(tmp[0]*n[0] +tmp[1]*n[1] +tmp[2]*n[2] +tmp[3]*n[3])/
              (   sqr(n[0])+   sqr(n[1])+   sqr(n[2])+   sqr(n[3]));
      result:=offset+n*factor;
    end;

  //procedure printContrationCenterStats(CONST cc:Vector4);
  //  VAR myCenter:Vector4;
  //      k:longint;
  //  begin
  //    myCenter:=vector4Of(0,0,0,0);
  //    for k:=0 to length(S)-1 do myCenter+=S[k].phi;
  //    myCenter*=1/length(S);
  //
  //    writeln('CC-Dist: ',euklideanDist(cc,myCenter));
  //    for k:=0 to length(S)-1 do writeln(k,'-Dist: ',euklideanDist(S[k].phi,myCenter));
  //
  //  end;

  var k: Integer;
      linearTerm:array[0..2] of Vector4;
      offset    :array[0..2] of double;

  begin
    try
      for k:=0 to 2 do fitParameters(S,k,linearTerm[k],offset[k]);
      result:=cross            (linearTerm[0],linearTerm[1],linearTerm[2]);
      result:=contractionCenter(linearTerm[0],linearTerm[1],linearTerm[2],result,
                                -offset   [0],-offset   [1],-offset   [2]);
      //printContrationCenterStats(result);
    except
      result:=vector4Of(0,0,0,0);
      for k:=0 to length(S)-1 do result+=S[k].phi;
      result*=1/length(s);
    end;
  end;

FUNCTION shrinkSimplex(CONST S:SampledSimplex; CONST shrinkFactor:double; OUT anyAccepted:boolean; CONST alphaForResampling:double=-1):SampledSimplex;
  VAR i:longint;
      cc:Vector4;
      accept:boolean;
  begin
    cc:=simplexContractionCenter(S);
    setLength(result,length(S));
    anyAccepted:=false;
    for i:=0 to length(result)-1 do begin
      result[i].phi:=S[i].phi*(1-shrinkFactor)+cc*shrinkFactor;
      if alphaForResampling>0 then begin
        result[i].err:=errorVectorAt(alphaForResampling,result[i].phi);
        accept:=((abs(result[i].err[0])<abs(S[i].err[0])) or
                 (abs(result[i].err[1])<abs(S[i].err[1])) or
                 (abs(result[i].err[2])<abs(S[i].err[2]))) and
                 (result[i].err*result[i].err<S[i].err*S[i].err);
        if not(accept) then result[i]:=S[i];
        anyAccepted:=anyAccepted or accept;
      end else anyAccepted:=true;
    end;
  end;

FUNCTION simplexContainsSolution(CONST S:SampledSimplex; CONST phiCenter:Vector4; CONST threshold:double):boolean;
  FUNCTION errorSign(CONST error:Vector3):byte; inline;
    begin
      if error[0]>0 then result:=           1 else if error[0]<0 then result:=           2 else result:=           3;
      if error[1]>0 then result:=result or  4 else if error[1]<0 then result:=result or  8 else result:=result or 12;
      if error[2]>0 then result:=result or 16 else if error[2]<0 then result:=result or 32 else result:=result or 48;
    end;
  VAR contractionCenter:Vector4;
      b:byte=0;
      i:longint;
  begin
    //contractionCenter:=vector4Of(0,0,0,0);
    //for i:=0 to length(S)-1 do contractionCenter+=S[i].phi;
    //contractionCenter*=1/length(S);
    //printVector4(contractionCenter-phiCenter);

    for i:=0 to 15 do b:=b or errorSign(S[i].err);
    if b<>63 then exit(false); //all signs equal
    contractionCenter:=simplexContractionCenter(S);
    result:=(abs(contractionCenter[0]-phiCenter[0])<=threshold)
        and (abs(contractionCenter[1]-phiCenter[1])<=threshold)
        and (abs(contractionCenter[2]-phiCenter[2])<=threshold)
        and (abs(contractionCenter[3]-phiCenter[3])<=threshold);
  end;

PROCEDURE findGridSolutionsDelta(CONST alphaIdx:longint; VAR outFile:text);

  VAR zoomPower:longint=1;
  VAR alpha:double;
  VAR fineH:double;
  VAR sampledNodes:array[0..1,                                                               //phi1_
                         0..1,                                                               //phi2_
                         -(COARSE_GRID_GRANULARITY div 2)..(COARSE_GRID_GRANULARITY div 2),                //phi3_
                         -(COARSE_GRID_GRANULARITY div 2)..(COARSE_GRID_GRANULARITY div 2)] of SampledNode;//phi4_
  FUNCTION coarseHypercubeCenter(CONST i0,i1,i2,i3:longint):Vector4;
    begin
      result:=vector4Of((i0*4+3/2)*fineH,
                        (i1*4+3/2)*fineH,
                        (i2*4+3/2)*fineH,
                        (i3*4+3/2)*fineH);
    end;
  VAR phi1_:longint;
  PROCEDURE prepareSamples(CONST phi2_:longint);
    VAR dPhi1,dPhi2,phi3_,phi4_:longint;
        phi:Vector4;
        doShift:boolean;
    begin
      doShift:=phi2_>1-(COARSE_GRID_GRANULARITY div 2);
      for dPhi1:=0 to 1 do
      for dPhi2:=0 to 1 do
      for phi3_:=-(COARSE_GRID_GRANULARITY div 2) to (COARSE_GRID_GRANULARITY div 2) do
      for phi4_:=-(COARSE_GRID_GRANULARITY div 2) to (COARSE_GRID_GRANULARITY div 2) do begin
        if doShift and (dPhi2=0) then
          sampledNodes[dPhi1,0,phi3_,phi4_]:=
          sampledNodes[dPhi1,1,phi3_,phi4_]
        else begin
          phi:=vector4Of(((phi1_+dPhi1)*4-0.5)*fineH,
                         ((phi2_+dPhi2)*4-0.5)*fineH,
                         ((phi3_+    1)*4-0.5)*fineH,
                         ((phi4_+    1)*4-0.5)*fineH);
          sampledNodes[dPhi1,dPhi2,phi3_,phi4_].phi:=phi;
          sampledNodes[dPhi1,dPhi2,phi3_,phi4_].err:=errorVectorAt(alpha,phi);
        end;
      end;
    end;

  FUNCTION sampledHypercubeAround(CONST i3,i4:longint):SampledSimplex;
    VAR k,j0,j1,j2,j3:longint;
    begin
      setLength(result,16);
      for k:=0 to 15 do begin
        if (k and 1)=0 then j0:=0 else j0:=1;
        if (k and 2)=0 then j1:=0 else j1:=1;
        if (k and 4)=0 then j2:=i3-1 else j2:=i3;
        if (k and 8)=0 then j3:=i4-1 else j3:=i4;
        result[k]:=sampledNodes[j0,j1,j2,j3];
      end;
    end;

  VAR phi2_,phi3_,phi4_:longint;
  PROCEDURE findFinerSolutions(CONST phi1_,phi2_,phi3_,phi4_:longint);
    VAR stencil:array[0..4,0..4,0..4,0..4] of SampledNode;
    FUNCTION smallerSampledHypercube(CONST i1,i2,i3,i4:longint):SampledSimplex;
      VAR k,j0,j1,j2,j3:longint;
      begin
        setLength(result,16);
        for k:=0 to 15 do begin
          if (k and 1)=0 then j0:=i1 else j0:=i1+1;
          if (k and 2)=0 then j1:=i2 else j1:=i2+1;
          if (k and 4)=0 then j2:=i3 else j2:=i3+1;
          if (k and 8)=0 then j3:=i4 else j3:=i4+1;
          result[k]:=stencil[j0,j1,j2,j3];
        end;
      end;
    VAR phi:Vector4;
        i1,i2,i3,i4:longint;
    begin
      //We now calulate finer samples
      for i1:=0 to 4 do for i2:=0 to 4 do for i3:=0 to 4 do for i4:=0 to 4 do begin
         phi:=vector4Of((phi1_*4+i1-1/2)*fineH,
                        (phi2_*4+i2-1/2)*fineH,
                        (phi3_*4+i3-1/2)*fineH,
                        (phi4_*4+i4-1/2)*fineH);
         stencil[i1,i2,i3,i4].phi:=phi;
         stencil[i1,i2,i3,i4].err:=errorVectorAt(alpha,phi);
      end;
      for i1:=0 to 3 do for i2:=0 to 3 do for i3:=0 to 3 do for i4:=0 to 3 do begin
        phi:=vector4Of((phi1_*4+i1)*fineH,
                       (phi2_*4+i2)*fineH,
                       (phi3_*4+i3)*fineH,
                       (phi4_*4+i4)*fineH);
        if simplexContainsSolution(smallerSampledHypercube(i1,i2,i3,i4),phi,fineH/2)
        then writeln(outfile,phi1_*4+i1,',',phi2_*4+i2,',',phi3_*4+i3,',',phi4_*4+i4);
      end;
    end;

  VAR simplex:SampledSimplex;
      i0,i1,i2,i3:longint;
      lastNonemptySlice:longint;
      sliceIsNonempty:boolean;
  begin
    alpha:=alphaIdx*pi/7000;
    zoomPower:=0;
    repeat
      writeln(outfile,zoomPower);
      lastNonemptySlice:=0;
      fineH:=2*pi/(FINE_GRID_GRANULARITY shl zoomPower);
      writeln('ZoomPower= ',zoomPower,' fineH=',fineH:0:9,'; (2*pi)/fineH=',2*pi/fineH:0:2,'; max extend in base granularity: ',FINE_GRID_GRANULARITY shr zoomPower);
      sliceIsNonempty:=true;
      for phi1_:=0 to (COARSE_GRID_GRANULARITY div 2) do if sliceIsNonempty then begin
        write(phi1_,'/',(COARSE_GRID_GRANULARITY div 2));
        sliceIsNonempty:=false;
        for phi2_:=1-(COARSE_GRID_GRANULARITY div 2) to (COARSE_GRID_GRANULARITY div 2) do begin
          prepareSamples(phi2_);
          for phi3_:=1-(COARSE_GRID_GRANULARITY div 2) to (COARSE_GRID_GRANULARITY div 2) do
          for phi4_:=1-(COARSE_GRID_GRANULARITY div 2) to (COARSE_GRID_GRANULARITY div 2) do begin
            simplex:=sampledHypercubeAround(phi3_,phi4_);
            if   simplexContainsSolution(simplex,coarseHypercubeCenter(phi1_,phi2_,phi3_,phi4_),fineH*4) //Strict threshold would be fineH*2
            then begin
              for i0:=phi1_-1 to phi1_+1 do
              for i1:=phi2_-1 to phi2_+1 do
              for i2:=phi3_-1 to phi3_+1 do
              for i3:=phi4_-1 to phi4_+1 do
              findFinerSolutions(i0,i1,i2,i3);
              write('.');
              sliceIsNonempty:=true;
            end;
          end;
        end;
        if sliceIsNonempty then lastNonemptySlice:=phi1_;
        writeln;
      end;
      if lastNonemptySlice<(COARSE_GRID_GRANULARITY div 4) then begin
        while lastNonemptySlice<(COARSE_GRID_GRANULARITY div 4) do begin
          zoomPower+=1;
          lastNonemptySlice:=lastNonemptySlice*2+1; //conservative guess
        end;
        if zoomPower>16 then begin
          writeln('RECALCULATION IS ADVISED BUT NOT PERFORMED TO PREVENT OVERFLOWS');
          exit;
        end;
        writeln('RECALCULATING WITH INCREASED RESOLUTION!');
        close(outFile);
        rewrite(outFile);
      end else exit;
    until false;
  end;

PROCEDURE optimizeSolution(CONST alpha,phi1,phi2,phi3,phi4:double);
  VAR simplex:SampledSimplex;
      i:longint=0;
      shrunk:boolean=true;

  PROCEDURE printBestNode(CONST prefix:string);
    VAR e,eMin:double;
        k:longint=0;
        j:longint=0;
    begin
      eMin:=simplex[0].err*simplex[0].err;
      for j:=1 to 4 do begin
        e:=simplex[j].err*simplex[j].err;
        if e<eMin then k:=j;
      end;
      with simplex[k] do writeln(prefix,phi[0],',',phi[1],',',phi[2],',',phi[3],';',err[0],',',err[1],',',err[2]);
    end;

  FUNCTION sampledSimplexAround(CONST alpha:Double; CONST phi:Vector4; CONST h:double):SampledSimplex;
    VAR i:longint;
    begin
      //setLength(result,16);
      //for i:=0 to 15 do begin
      //  if (i and 1)>0 then result[i].phi[0]:=phi[0]+h else result[i].phi[0]:=phi[0]-h;
      //  if (i and 2)>0 then result[i].phi[1]:=phi[1]+h else result[i].phi[1]:=phi[1]-h;
      //  if (i and 4)>0 then result[i].phi[2]:=phi[2]+h else result[i].phi[2]:=phi[2]-h;
      //  if (i and 8)>0 then result[i].phi[3]:=phi[3]+h else result[i].phi[3]:=phi[3]-h;
      //  result[i].err:=errorVectorAt(alpha,result[i].phi);
      //end;

      setLength(result,5);
      for i:=0 to 4 do begin
        result[i].phi:=phi+SIMPLEX_NODE[i]*h;
        result[i].err:=errorVectorAt(alpha,result[i].phi);
      end;
    end;

  begin
    simplex:=sampledSimplexAround(alpha,vector4Of(phi1,phi2,phi3,phi4),pi/FINE_GRID_GRANULARITY);
    while (i<99) and shrunk do begin
      inc(i);
      simplex:=shrinkSimplex(simplex,0.5,shrunk,alpha);
      //printBestNode('* ');
    end;
    printBestNode('');
  end;

VAR parsedAngle:double;
    parsedInt:longint;
    outfile:text;
begin
  DefaultFormatSettings.DecimalSeparator:='.';
  if (ParamCount=2) and (paramstr(1)='d') then begin
    parsedInt:=StrToInt(paramstr(2));
    if FileExists('dc'+paramstr(2)+'.txt') then begin
      writeln('OUTPUT FILE ALREADY EXISTS!');
      halt;
    end;
    assign(outfile,'dc'+paramstr(2)+'.txt');
    rewrite(outfile);
    findGridSolutionsDelta(parsedInt,outfile);
    CloseFile(outfile);
  end;
  if (paramCount=6) and (paramstr(1)='opt') then begin
    parsedAngle:=StrToFloat(paramstr(2));
    optimizeSolution(parsedAngle*pi/7000,StrToFloat(paramstr(3)),StrToFloat(paramstr(4)),StrToFloat(paramstr(5)),StrToFloat(paramstr(6)));
  end;
end.

