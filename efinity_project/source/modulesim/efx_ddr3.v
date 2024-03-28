//////////////////////////////////////////////////////////////////////////////////////////
//           _____       
//          / _______    Copyright (C) 2013-2022 Efinix Inc. All rights reserved.
//         / /       \   
//        / /  ..    /   
//       / / .'     /    
//    __/ /.'      /     Description:
//   __   \       /      Top IP Module = efx_ddr3
//  /_/ /\ \_____/ /     
// ____/  \_______/      
//
// ***************************************************************************************
// Vesion  : 1.00
// Time    : Wed Jan  5 10:54:25 2022
// ***************************************************************************************


`define IP_UUID _a0e9846c6ccf441ba24c2db2f06fd2a7
`define IP_NAME_CONCAT(a,b) a``b
`define IP_MODULE_NAME(name) `IP_NAME_CONCAT(name,`IP_UUID)
`ifndef VH_FILE
`include "ddr3_controller.vh"
`endif
module efx_ddr3
(
input clk,
input core_clk,
input twd_clk,
input tdqss_clk,
input tac_clk,
input nrst,
output reset,
output cs,
output ras,
output cas,
output we,
output cke,
output [15:0]addr,
output [2:0]ba,
output odt,
output [`DRAM_GROUP-1'b1:0] o_dm_hi,
output [`DRAM_GROUP-1'b1:0] o_dm_lo,
input [`DRAM_GROUP-1'b1:0]i_dqs_hi,
input [`DRAM_GROUP-1'b1:0]i_dqs_lo,
input [`DRAM_GROUP-1'b1:0]i_dqs_n_hi,
input [`DRAM_GROUP-1'b1:0]i_dqs_n_lo,
output [`DRAM_GROUP-1'b1:0]o_dqs_hi,
output [`DRAM_GROUP-1'b1:0]o_dqs_lo,
output [`DRAM_GROUP-1'b1:0]o_dqs_n_hi,
output [`DRAM_GROUP-1'b1:0]o_dqs_n_lo,
output [`DRAM_GROUP-1'b1:0]o_dqs_oe,
output [`DRAM_GROUP-1'b1:0]o_dqs_n_oe,
input [`DRAM_WIDTH-1'b1:0] i_dq_hi,
input [`DRAM_WIDTH-1'b1:0] i_dq_lo,
output [`DRAM_WIDTH-1'b1:0] o_dq_hi,
output [`DRAM_WIDTH-1'b1:0] o_dq_lo,
output [`DRAM_WIDTH-1'b1:0] o_dq_oe,
output 						wr_busy,
input [`WFIFO_WIDTH-1'b1:0]	wr_data,
input [`DM_BIT_WIDTH-1'b1:0] wr_datamask,
input [31:0]				wr_addr,
input 						wr_en,
input						wr_addr_en,
output 						wr_ack,
output 						rd_busy,
input  [31:0] 				rd_addr,
input  						rd_addr_en,
input  						rd_en,
output [`WFIFO_WIDTH-1'b1:0]	rd_data,
output 						rd_valid,
output 						rd_ack,
output [2:0]shift,
output [4:0]shift_sel,
output shift_ena,
input cal_ena,
output cal_done,
output cal_pass,
output [6:0]cal_fail_log,
output [2:0]cal_shift_val
);

`IP_MODULE_NAME(efx_ddr3) u_efx_ddr3
(.clk		(clk),
	.core_clk	(core_clk),
	.tac_clk	(tac_clk),
	.twd_clk	(twd_clk),	
	.tdqss_clk	(tdqss_clk),
	.nrst		(nrst),

	.reset		(reset),
	.cs			(cs),
	.ras		(ras),
	.cas		(cas),
	.we			(we),
	.cke		(cke),    
	.addr		(addr),
	.ba			(ba),
	.odt		(odt),
	.o_dm_hi	(o_dm_hi),
	.o_dm_lo	(o_dm_lo),

	.i_dq_hi	(i_dq_hi),
	.i_dq_lo	(i_dq_lo),

	.o_dq_hi	(o_dq_hi),
	.o_dq_lo	(o_dq_lo),

	.o_dq_oe	(o_dq_oe),

	.i_dqs_hi	(i_dqs_hi),
	.i_dqs_lo	(i_dqs_lo),
	.i_dqs_n_hi	(i_dqs_n_hi),
	.i_dqs_n_lo	(i_dqs_n_lo),


	.o_dqs_hi	(o_dqs_hi),
	.o_dqs_lo	(o_dqs_lo),
	.o_dqs_n_hi	(o_dqs_n_hi),
	.o_dqs_n_lo	(o_dqs_n_lo),

	.o_dqs_oe	(o_dqs_oe),
	.o_dqs_n_oe	(o_dqs_n_oe),


	.wr_busy	(wr_busy),
	.wr_data	(wr_data),
	.wr_datamask(wr_datamask),
	.wr_addr	(wr_addr),
	.wr_en		(wr_en),
	.wr_addr_en	(wr_addr_en),
	.wr_ack		(wr_ack),

	.rd_busy	(rd_busy),
	.rd_addr	(rd_addr),
	.rd_addr_en	(rd_addr_en),
	.rd_en		(rd_en),
	.rd_data	(rd_data),
	.rd_valid	(rd_valid),
	.rd_ack		(rd_ack),


	.shift(shift),
	.shift_sel(shift_sel),
	.shift_ena(shift_ena),
	.cal_ena(cal_ena),
	.cal_done(cal_done),
	.cal_pass(cal_pass),
    .cal_fail_log(cal_fail_log),
    .cal_shift_val(cal_shift_val)
);

endmodule


//pragma protect
//pragma protect begin
`protected

    MTI!#6Y}]]"-]ivi'!{pkGK<Of57E}E@Te=1iT7Gri|isE7j5z,S8GZvnN6FhGrzuGQVie#7]1\@
    rqC|z3C[EfkQ'Be-e]iXa[zx^QI}VCXjovVOuVNWs}jzRTAB'YUj+^[iT;vvS7m[k|@l'wp~w;<T
    g2O'<,eAT3wWA*;-5_=z~[lOB_YxZ>VuT,wu]U]Q?h[Q#Wr\lUg>RV,iT3;ok+XuAV[+C35EXrEA
    1i'&eW@?;'H*}!G!~aRxe]#so<v{]C]n7;aout?T,2X{>Z^WKo]+]_$*nDWa[#lzpI]mQQJw\8=k
    V{|Oujl~+ID?1#U'-@I7uG\}?omq,1W1G[<e*Zj\eO,nQ1>wR_+RznZ~8eHl}[l+B1J@;xI?Jx;~
    uXXeX=B-Jw]X7@*ex0GZC}kweaEC]2=*E#gi1,an$wpxba'-=EGHuk5>DEX2^%Y-D+t}MWE\7\e^
    zl_YjIyj;@WEQpBa5SX'feG@E2[_ICu27+rs[:3H\nH5HU
`endprotected
//pragma protect end
//pragma protect
//pragma protect begin
`protected

    MTI!#!,-a1\o'3GY#5VV=;v$l=]uBpGVCjvE}|)H<RiPBK[a.Ho2?CI?#<sK!}/M7O-lB-BT<1x,
    AwOU<sk7_rPlwJ#*+[[o_n=['CW!Ul$HUl5C[HEIMU}2,-rkT;5L0kDm7-+![i[/sQw17W;#'Gxo
    ?Q3^N6p;J,msAIO=zasD$p-ae-iar3WRuC[O?k$QKW=?]7Wpx?oW>e$Cp'<5V;u^WIARzEGTYWEq
    >T[[<nUC,O;GlPO>l,+T7;2CKTnRJYP9!&!aOT:D_,Ua^1xU^W?1,vH$GxKaHxUy]Vne7R17v[Gi
    0,$RaW_VV}ypsY##Al^FL:QMz=J,^4/g[?3'xWzudewaBl@|{5o>-a2nza1${=w_+s;}g)1#s>|m
    YuD79PMzHBil,{IJ\~Ci>r*'Ta3#T~B}cHwleHX-rooLQD3{aAZ11_IQJrkU+D!W[cC'+KW1,Qrp
    \mTXbB]<$!,V[r4Wr#w{^?p'7>uN0rY\n^{GZ
`endprotected
//pragma protect end
`ifndef VH_FILE
`include "ddr3_controller.vh"
`endif
//pragma protect
//pragma protect begin
`protected

    MTI!#DU@'V@3u$s7'3R128=pDX@*B]..*Hl#No#\@|%$!Yu+1Z*JIA2<A~2ZNCZHev3n-iB<e!]^
    G>'-#[mlz77?@}aJ35/o_n=['CW!Ul$HUlz.?\*Q'JRrck^m*<1Di9oGw}5r=x};-Vmq5nnu=L<+
    Rs5vQoUV-T#Yo]!5+TCk*G?rzU,KT\{>}!$k;W-,E@_*u>_saZ*#ZGl7!}z<~Tl5l^?YXx"57?*,
    pn@)i{{lWx'\SX\#jx=3Il!KzsI7!e{\EW}1_>7,r61;Dm72'zJpEU&{$JB$AaBMo@uuVo[llH@T
    r#s}Z<w7UjU3v#X_h}3wuJ}JO;O!ZB'*HOAoWWU<JK_[^pUa@-<}H}-+vNYToZUxEoa}W>{\KAwo
    kH_;A\=suKv?IHv[Az}+x_Noe7Ds$O-E{Qu'CQiC[;T01ee<TaEvIZ=#+1J'"DN'OTv|0<AQo{om
    wp!6@[B2p_p?3jnlIA@->aTe{52JJ7n_@w'zBo${K['>5,XY3CkACrQ?Y-;]r@YE2}<lF6~}X<\$
    #X1+mps{JZEOiY'}os?RXpAj+3ozV*p!5ATrnIewT-*BQpxwl]+z71!1_l5mjAlX<spK{EJozl-U
    xX*vs{$w5,E2_3_W-G1\+U}kDZU-z@KlI{p;p53Ox1_5@JoO{r>V{aeY>+@H~51]jofw'KDH5+wQ
    x+[W+}GUrRw=k!Y5lm^MBLYwo3&/rRR$GHx-Q;YEr'<Qo,vT>r+DE[2Z?Cm-GDT_H\R-J$=^jp;3
    21<k/$V{[Q>s!Ev,11n@jAE1]xZXeC!vp;xmu~nx@Jp2QDiTpu*Xaqz?1iUGopoQKEyxQHR2]<ro
    [i*o@w~+Dk7,H{G.]1oV#$\[d}jV;/k<lG,4Y'YzHz[U.B=32KpEi!oH\9P!}>^[XO2n7lOl>*Dx
    iOk&@,5^W}O*7^Z5K$Y+}<Z~o,;R\CI\eGp\URA,3H\[o<\O'_='I\1?j#u7],IXur$l7*Huw[#G
    4GO~7*37?mIjvW};2*<lApa<]p_unx*w3m>s[U{YD9^.zusj3OEi[v~J=[#~GoCDYn^ClCQXs,ir
    ]rrB,D}vQek?1?w^2ww2S',;?_Alx3,k?x;Dr=Z@qZRAx,\rCYAr2,?sV{Y#@O*?3K{1u'W$_AO^
    T51mG.%u1G;!wEWNWCnIvsoa*}RUeW1vko_J<$_]m8iT!J}@T*EOJOVwGpmzR@\vQ,\#Gw.G#aT,
    UCKjYV;IiQYa-mVboxxGpDY5EDJn:PfUjpBz?-~jrW#SQHJ'(VQEBtV3JBsV^=n1?\7}{ps-H~aA
    {u[$2j6CG{$x$;s4EB\$3Unx/x'}s'!BnQx3=Cx{sC3*w=e[g#rvU3GKaa$i#?NF[2xj5j[@#xn7
    a-\r,@xZNE~5sp]{[;\[7eKEHI(iU$o*?K[LJ1CC~]\kT=3Ie{_rQ=zAWv}[=KvAWl_up~ewK$Z>
    ovYADDH^,^2O\pXkPX_{3emKTv,vA7;rOHOHaTx&UaI#O3>]8{aGs_o7@UQVWaz?Cj*Rp+{e'K>Y
    [,*#Z\U$=ZD'aO1-ovVU7]JzoVE[#AGuvp_jZwvxDb=@o*zW7B1OD\-VQU,$sw_Cz[nVi$||\s?l
    veH^C={,^JR<nY=o>-v<R#pjwAIKm8;>ao,Kms_#7E7zX;i}sVw5ZXG3{_'[p5]KKBOGeW_XVuX+
    '-Vepu*ujJ@j]-_-Hp@sYkp*+Zl;sQxiu2jB1[Ae;lB+!e[vZRKD2A[VkpiBIrXzKDA^UpH-3]r~
    X^9lkw_R?~UFO~jsOT'5X_<715,7}Rll-IIB]auV(#nxY3Ul~5u'$pa7nr@Davk$*=jRJx^D~{H!
    !@x-]T[O'ERQ$>7m3MCEoeGp<IgE~1+<v?U7l5uUxR\;,+zXRX+=[j~__YeUxG5mrunRTx7Q!<uq
    kE#AGZ2$o*-nA,{?|},=u^_Y?Yl!eYB5elnYU+wC~G]*Q8_=,KQTEDHIX^'Y}O#aJ~,{vz$Vx1<O
    ma~VvOh-+D\V^,]lHm]s=EB?-~,/lJW1]CTs]5n,OZEJ{$uB<U1,UV=E"B[Da]V,QJTlK7jOCs?r
    kKB$}<$'n\ne@_E@AJpG}3[7VIX-<j?'OpaTpkY<VLLBDOj\{!ECxzuosiz}r+O&TX]w*sU?A[<K
    1^E~uQm-}Y=Qw[u>9z\3UTl[mXDGz{Bk'T-=jeTlDLQr[e;52p"~v=1pJa]+XH{*kw{-xnl"lj-?
    [5Hjj@-]75RIpdZ'X17G^UxiIkIEDe@zXrwOj~bKzpA'ux1>*Akzr7_,w=~hZAnv}-1A53;}H{@l
    rV~7m];rEOVDBIAe!->~.n>r\,JJ$q73rjDJR~XX\WXp@eF;nE#yx*eXO\Q<,m@>_js~s{K1CiZH
    LI1V}B+*>rTW;Rr^mRnsC^!5GOuAO8pXZG+^=zoG?3oGVA8w+Y$c43]O@xc!pWuI@qK7A$,|spaz
    I1Q#'bVAU{op}''aH]yL\QlQb7[x3z+s-3nH][iD1AaZI^UHZ^aXYt1[-B'k>=e>W-/oH*'Y'Ga}
    &b7v~C1{1idE;<BlQW}9E}UH>=iurE[O{-[YB-2Hap7ZVi!Ql?vwYZ{OT=G]7so>rDDVOwTODvhR
    }?3$GQ,H5XX#EVK*o!'lun3{}1w~7jvpr!Tn+zJuE>TJ']n[iDJ'}sA7A-u2au{pB#<Gio}B?ZZ2
    X'ai}W#Vr^_]YxU~}XI1GGEx0b\}U={YrQUOI1_sTXV5Q]5Yv>YWAK_+vp3]5!85s>>8I>ueLJr]
    IvB2,lmW=wC,R1r\aAee]nj*a*9a_]U?_U?I2\nv-73Q'o]^HUATHTCfCAT\R']aVA}Jk[,Kftn-
    Gl.Jz-]SDlwnR[>K?<m$%uOImR]Ax,@vJ{1^2[!-Es<*Orer-5;B<$n~2?Tw]KHU?:-5[]p'7O]'
    QIa\vWl-@,'X[jLY,wT}5Gjin!aHV?;*e7<2R{_O2W,\@E+e-r{^m3H$}R3#OVjO@B^=+KnOC3'Y
    Ro]xY<Z7>]Vc=oZsE[j7!zI@vHX3p37'r+;+;UG}EsHRGT$rKRHDolkuG1C2m{YTr!-\r2oa3CpU
    2E<>ru,@HQGnmHEeK<*jD!VHIY[u*zY\Aa>1z]7lZ7Hriw\w%7pViEY\[B+JK\GNu\rAKG*o_X-*
    encz5Aa@pmoQl^~z>I~AHaQNd2QjUkjljB<{7sxKvR[Z,$]7_C;BXRu{V$AJk-jVY5$^pW$oD@\v
    u[eYW|_H^,C+$lZE\JvoQ2y$_+I!REI/pZQ7]lDe\]+uROz[V)Kti]Y_ll@jo?O7l3Z\sAN@Xj*h
    _e+^#}p5W7+\_<}G^Wm+I-$n^ws>;sm$lKWTe+nxxpvlFWQjolZo\C{sD\$+U+DA*~r,=l[p~IRA
    Zs~\iOE2jo~2Z<TZY]5mxrTK\^RVD*>~RUvvlxe*=}*AsBYa-Fm>!j^>Zr!=Rw2sKAJD+~e1xC.j
    RU]>$G#{N[G{u,zT,Y+${52*Iy{R@?BVIx;r'QXX{+eJGizXYWx_IoQ+Gsx}{@rp^a-wBs1w5O~$
    js>XHJH<2\C%E1!E7*=E2YT=x@E~$>*\^BHEoKB;mj}@e?aGJ1ejL!BW,y@*1pRs-YGvKkC,*rwB
    V[HaZ=IW-l-jz5mAZEQnO['IDxipI2;Ga_Rk!n]U\Z#}mrOaZ<#6jHOBs3}}Q?Gj'z]aD;T2}j,Z
    zl]#eno3ouU1~Yv\K5Tm>D,xs>X{EvK?s,_;so{TOT~^n>vED~He-\eKnDnI2Upi-j^zg"}~Q->w
    Z<oYC_=v@p0Bp_2zv*A_CK}w5wU']<~;^uA@HZ7m<ZWa=a!YUv+=?*pzwe?w[xJ?'T?Dz}W=KI>~
    V{@PDX7ufC+A@do\$m]Oz,I>DIY>u$?x#~lNk5jK_{_{XVoxV}p}<Y{;-[lilmAH1po,6JCw>CUV
    [3>ZGhP1j+@5!u?E^@l-B,ljpAR)<'GJ}C?KviZlJAK@H$D#vkDYOA2>-QJO25^{S\i~Rd(oHlsz
    E\w9#5{+Z}C]l>23:qN[mA=Uv[]I^V;}cnsVQQ@wB/!'!?{UGGRJ^!RXRpRaA1,1,,J1\7jrCXH5
    +ZoAX\KzEsjZB@lxuvl2napoQ;sY?OYFxvHkRBp=\X@Chn^7=^kX*p$BIm*'pp1DuijUQ(!_@Z@=
    w;|QpjC]{=B,z7A/5#Y#Hoj\ERn$*>,+u<\Y/,QnJEAB.=>rK>7A\~HQ\T]R\<sn$Bj3w-rK_Gwm
    ;B#},rj,Kd>7Gi!s5^5I=,^3${$pu[O~D@JUWEwTH_S}lUE-=D]J>J@xnC_T{wa}aWTI\zKB5E5c
    5nYRv9<|%pRm_E>xR(Qt+>3RiD75Y+*Z'%\k;'>e={?{E#&A7aE$>l;l1jI{X^=wwwns[kYC{B#G
    u-3Q,%=^<wxKrKowHsrIA\'5K@EUvUT}Qza1>+u<UKe=Ap*X,>,QURUxVZ,\u=eOXs]Xa_#aI5*G
    ul,]>l9{aT[YuC}Yr2}@HK'lnHjeXRB0;Ew7G@$eKw[D^_Ex#55ie-'ues,ogOCa{csa5'l,BR^7
    RT:[!T=D'3u;^Xv,Z!AAnUj#Oo?^Cm+^!xksX[3.+Cm>=*U*I@V;Fc&GYew*eu
`endprotected
//pragma protect end
`ifndef VH_FILE
`include "ddr3_controller.vh"
`endif
//pragma protect
//pragma protect begin
`protected

    MTI!#0Aos3(WGk^Jen^{qWxv!@*B]..*.:No#\@|%@o{J+oz*JI{$+AZrvf~Oo;,#K^Nz3HxoB6<
    CXTzGC[EfkQ'Be-e]iXa[zx^QI}VCX$E]orBBN@'}wQE#!o!oU;$'o[-zK{EB7*r#-EaBvp;vzII
    x<3an?'Q_rW=w7Ga{sR[3}X5B+NFQam$ivjQpLT]T5KTI{3zlzfZxOnW<xeew<Go,\pxCes?lDH4
    }eH\,$p7ZlB]A=eHBH>5sBUQkoAJXoH>'\ACpXj7%ZH]z77$$fDwaJ+V[T$7jCl3V7zxO#d*rDwp
    COZ7#Ert([#}IYZ=\+B{T?'U1<saCEO-]KDUolUm}pxE#vW*[jH^1?IeD_5a1Q1z^VE<!iz]3p-2
    uo^oV-pm_2eE*SXja#Q=@KLlX=;*HDu7j<GIl{$U,GC[k\A'jD<+BV$E!<-Gr=m[o^Uy?[lCB,Iu
    o++CsQBJZ<ArQk7^OZ>{P;>e-2V\5;YXUxU}zBh/Cvr>Xr3O$\JlUpskRm=[Q-[J]o[oG-pYk7EH
    2nOl*THodYVi'G>EjRpDxJBK3}G{J'-B>t/}U*O^@,AIZ2Z98'35jma}J?^u~#CWnBw\s'rloGRE
    x}1yJ}!p$iKVDp>n*WapuI1I;Rr@_esUR7XBVJHwI$>3B6n<UHewrW8F7$AXZ$k!pD{~{vOl1;Go
    'OuD$Duw^[p_ezpwR$}zTRToRH+WWXYR*<s-<Rz3ExQpIJoxp\>nPHH<HG,_!B[T-ZjnWABr3ACT
    kC2!37DZaxZX]r']jj{Qnk>3ln\oG!BX!<<n@v>B3eO2QinA-%~1*7A=lZ\rmG#[OJ+5nRBo1E~s
    RX}s-UUI~H[_7JhEITTYazUxvBJ/\[RjeU}Is!^~[lmG7!m1^O$=-<D{}CYwj}kaXX3EQ\@BDlr]
    O$oYDYaRArU~nji+y<DUu?{YaGi{V~=ipm{u}*{Kn>$!R&r=<V[H>GTnQ=irvl3R<alZ!ZR-@VI~
    !jHRX^8B~x_eD];i,_[E]wD,~nTj5zE1vm;w^E\}pkEU'ep*21aBnn,T\+}'O;Y5<lD]*QY]@O}s
    K]OsRQC4vU'B]Dl[CBrW#+BkYZZ}YI,K5k@ra1}\ZE;AQ?Z!=uWmb%a+-v_7B[c1i\#X>E3Rpaou
    ]DTYaYn?+Opaj5Y]wDmR}XnVr_[*.qiB]#_K*_'7J~;[KATrA,K-m\SXCxr!YJr@'HXf9Q!K';U*
    V:{$X!w[3W}_ZoTVH2Oo53eGE@;7IR~s#YJ5X-xDUwETmX@9}v?YU|uw2>_l_~}5p5U=ewyv1};O
    xek;$[s!{v'~G_!C-^@*HWT'C!![]+kPVRHmGml'lYlAawXkx!]o1kX_Bnz*HBm}s]WR<&=H*@I_
    uKm1Wlz$,5V{>2P#UXpt@j##?7u1c#_A{{D+v~_QBW>xoT_7Os>ja6vTC-YH[=ZH'v?G^HvY+~CJ
    z}l32O=TEuKoZABZ*ZY#p<}fy^r*v},rrpOH2T*l'|J-<u$Ip?LQims7=7<}eCH\}R[rZ=Z]33]l
    oAOG~B[#TI~AxwTZE1xz#HQAXODkaIoBo52d}KG#[AARWas#fj?ZG'Yr@^aj']+B[v"Cr!E5$J,R
    ]++7D-XY/2[?<iIKnh^;\pi$T}JRYYMUsvKo6g1?e!QC#k5j7?enG'lR^A1]J5V~Ii8E=r\LV-x^
    >-rDoi<1f;9h1<nsC{7iCk@RvOZw5DV1r;<3oI\u=_O?2x;-5_~os<-,esjj~5Tz+I}R!v;@B[T_
    Ns{5_tVBsel1JY$uR^*xm{v#\;ie!~@'1]!D_i=T{*ve{?~>1a),pBQc?_zT3v;rKjia>,-oS-l-
    Ti^\o?o1}9JA<VFQBvTT[Qs=wTjA*XxG-3]_{ziz*}_Aol}vWOIz+3W^X_Kb!CT~-p#_h'2JJ~jk
    JE]H@,\XT>wXB,Q]O-Om#5CHpC5R]@,R~o0KYR$y5U+3+XQ5[~'\l+{5@HQk5R2$m+U*[w{?rM?O
    ?5's7U^8z'H1J>$})^x!<]=;<<{s~[!p?,pJQ};m]Gem_JOp,S_@wB;UD1O$v,Y]T2l_k;>oR!WT
    EUzkX{j^X*f7r!w1$T!Pv}[n=-{kGwoCr=T,3j<exz1'vy3s{V-Y|$m1XHep~,\X}Tz'~c?\e2'd
    _5,Rb#^K3jJa_XesGj)R\@<DVZ*?CaZ,Y[Iieo^E#3@,GC?Tr#ZBUB{rI?jUBeOr{n%'DI'2-s^[
    T7RH[i_0Xlk5He23R=uvyIp?eO~eGmsnZ,[WE;E?}bvz8_-w[[vjmDMu<wp"UIH=+o-x@OR$T_AT
    pa+{fF+<DuB!--lzpwYQ!^e)}s^wAVl,,V?a[-!<ow-B_-O2>w*[78CW!m}1E}U$T7WsA]Iv@@'I
    s7t3=\rJ'<ogoeQ{u,TV1<3'Z^Oiz_IxpiI9[e{alWpo'[zDlBxmv7;Cq}1-m<1n!?+jKK$V~~{{
    s9wq:IZxpF1DC@c>\HB'B[Y^m[oDJUB^Upo#sQpvGw2p?<7;s*xRI>1yV=$^9p-{ItY\T~z;E\FJ
    1nj]njn]}*_w]-zH{R3a5?Gp-Z^G<@]I@Kod%oB^#(aC$]t"(#oio}TA!$O$]^i^C[^pJB~pIHGE
    KRZ=suBA+P7YB'.u[<^wX=!K^$77DO!-lA3mO_{\vp~Q$*I+w=E>G+{D]K3r,<l7}*2rrV7jsH{7
    AvkoYR;'HEOR~1}"*=Om-[^KmAVlrkY{#ROu*k1sE?OR5K^78|VA]^$k17+a=@\1!YGim?skjrc;
    eGn=Cm@sj,!}D@zAY{^lnuuoap@,X+W{}O[H>OD[$WHJ]-xEB>jKQ*l,a\1wA+G7rx>5-_,FM@al
    EV=m^}+v\E_17Ew\5>Hmr;IQY[Y+Zsu'[3v3!Q,s1lHo>7OVahIR\+@-aH3QA\Q%knJ5upOkKesG
    _s?HiD_TW'JJr?zjRlrzCpJ@0mR5xV]XZa_D;YJB7\s'R*OQ{Ur!B$rYn;D]]i=2O]em_CK<{fr_
    Kwp*$$-H[>r'm$-HpreK+oO_Va8*GH^,:pZOm=@{=,>@CC:eA1\3A*3E]Tx7a<ppv=C'+&R_ARnE
    '3[$vik5O'oJsiJODBD<573sU'jtYn+YO'C<lH3'$_>^+}Re$UH_8Bx1OIV5jspBTm=~a*RCmuoE
    <Q<*-EuAZ=R,zhV^a5}a'BQ[x#zJ\xeE>ESTOCZx_1[qgj-xw1,~7#<*Cr}UD\>QwQCIB%htYBe^
    v!mw2D}!fDA<G[TC=:~]kA]O5TACIj-rp=,v[_;X'XnBo,KC>RL$kp2W$C^Uzx!,\*73->$'pI$W
    sv]x?Y[}{]Kse7aRn[uTDJ*T,Zr!a,!YJGX#wqPZ{JB=kaDNqBCUY&j@5~ov\[K_=$K=}2P>sl$]
    [V2B>\a,3]u2*BIZrO{GKAa,Bso4OKH\)_<jY"Fu[]Ye>J+2lZR_![D'5B*zqc<-3>.KGw]i=UTs
    e{$M=$$WQIV}VD751o,xrDD*oIeU2[\XfQBiRvkDsOQ~u=n^+FrOe#ra'xMGB]v5-YAWv>Rj+21H
    o{1ePY@Bo2<1De,7QeZ}$sp'JN9}wXe~HxIC-}wg}608iD[pUene_Ye~53v^A${r]HQUzf?$EE?{
    mX;xvu}ek2G*'J2_YABj?e~HU_:XO};;-&,IZl9D7!DpUK<wOuuex'xwYumzBkkCI@{}Yi#!U{xp
    *C~2,T@/AGk>#=>^lDV!?1?r,vp2Az@7Trn2\1!?'Z3{55z^p'eXGkG2?H\;I@jUv~Bw=1?DW*HA
    }AY7~}lv\JIx<,\T!.=kA[1i_VxaXJ*^IuZX7H3>TB95{<<x;+XBlv1-T1Af!E*Y]*zGv\TY+YsI
    <Y3{*eO$AvKDe5\;Ov$K>$!Gn}UG$DY*'e$v_juTW+eW#>@v7G~*tXYl5Epr~>TloQ],z1z}^#7H
    HaTZ]#RIV{RCp%QI['@-]ktnX~7g#w^uuGRk=*^?$:PO'kBw{~*zv>sf~1rT>-<7=WVk!ACZK,xe
    1$m=Q-\Al=CvE2r\_[tK[?Bh?}jEGN"ye@Ha?{EUrw2>Rp$nrR#pYnW<M,jo2ImAvBCT[{A>>w'e
    eCUeTK77GQr<Oa,ZOIs]l>}uX#6&<-{Re#c2Y5Tk]}l]^Z]3slIJw$Q[K\Ox,WzT\uD]n$!a=+2l
    /5Bprp<3$B+W!vx*m|tCw33^R3'Rpi;k5XB6Jse5BlVJDrD{vEkG7AIs>T3B>G*eYV=^<\'oj$$_
    *DA+\xR;7U*XrTQIo{VI;T~-HG>H*}^^T]Kv^$z$Tne>mHIJ1[-DC6~Ii!.j~Uxiae-l;,[9^U=@
    Q2pJOk13@a7Yr1j*\OD+\,ili]$T}l3enT>p5;RJ2_uTlVC>pDkkI!R@]pm'K\e3k{l}i]5jo<DU
    iGYnV'fBTTAWz3klIHjSko,C[,;'G#,@|w<o\2$5=ulp*M0OGK^W>*]GGoRa^{V2'I?_sj2ye5V=
    ^!T]E[jY4Q}*o$vw<jZrYG<m+o+^Y,Xle=RC]1upJi$]C8+G1s~YE_7=-uI7kp]>3jT[Dj$2-z5W
    uO_mC},vCrXEm,6n'>B]*~GHV}';1k>8[ZKWkEX*vIJ1yWEujp><>]'UnHC_;BVAn}3wAv1Hnnzx
    ]jk{?C@,Cq{|BTX{;{W3\_=u9E}@*~-Cm^:!}no[s'*ejjn=!}\$noRpmxoCD_Ciov5x@=w2<751
    Rxu=IYDy2_r+e}.+>!QB?oejO_Z+5R;_}{',sKv>_Bk*B751$+*i{YW=X=Aal*O~\w,ko5{AYvU=
    D@D-pxA{_E#*$ADj!B\e?*^G#2^Ik^@v*_oBRnAl,_kR,jY|DD]loV7x]^72*m\XtA$I=xxWVB"u
    1!5iURaa_zUHa!oo^jzEvX^]r\AX_EXU[CDGAo$e}#Xe;^17e+D=u1pYuel{Q\s0p'-},l2e=^}{
    K_VQp]u~1+~p.bRu'~?$kOG]kR2A1$sOPa}B>;$pV-[3\kR1G5zaJ)R^xXHpQmr_\wzrz7[3~e$K
    !oeAjlbQVYA'r#>$CQw{.aO+GIZGuunGiD?*jHlVGzO,$9r7VOwVW_Vs=*e?XXDr7epC(*Vrw-em
    RnI3\(ka=3HVZ?]'kk'7,AEE7nAzVDBB>@sj1@;Us+Y]j~.IWHrdTp<no<~$<e}o1\Du>}_kp,uH
    Ka+Z}JVrl}^RGZBj1AQ[,z!UDI\CpTX*ARAmn_<2-+$[i\xozJ@CTU*Bx@C(&%#T_XB<_^BCK3\3
    wDv$^plW23XsJuzV+=,Vop+jue\<,{OZrj==ji!nn#r_X*Av;s[-o2wD<Um<WBlwpRs=+k?T,OTU
    ;27k\@rOAOA>$Cu}\?*zm<u1V\'V1J,5<Z*CJ!f-pJC7{o?_aj1EW\Zl3GR4nD=R~w]5qsx!]},!
    TxYX$$s?'->Us|xDQZOWWp<'X]p7np,xvuU*[G\UG[V*rjF]~V<:}[_r+'sX5U~_Bk\=xsHsEW<K
    =!EHrC7IBCKR#5D5T]YYXn_$2[-kRHRwpp2*WV*D;RU<e-eR_[2nGbQ_\,so!A{Xar=.CQA@W,_j
    ToR{x1<TWrv,nsr\o@Y1p$JDVr_DAR$-I^n5=sa=JV>sDnI2^Rk,IoQXCXUY<=,Uq+I!VM#O3'}a
    ->aw,{YEUQWw-UVR<B#$Z\[<>zRg7<xilO#U<^5;}K*xV?I*'BOB\s$?M\avW<wW'vE{}^\5pCiC
    k]_apFVMa5]^=~IVoKoJQ7riB_I#R@3*a1XO^uBiVU*;AV?#JI*Z#D5B_oHr"rTA?@=vTzk7Y1<[
    ~n]z<37xpEnw!3=B-v3-<~z!@U++V_1X<,;p-;-,uO\l?oJ'*RV7{>*Ka#sUKn,Q[+LJhKR$\L{p
    ]G<V#Xk5,e:(^O8*~$AGvrUUoH=oQAZlkR$|lPqeTWGW[B{3+lpZ>H7<,pa]7w>>O~^h=@,IR_Rl
    vJm[zOv@HEp>ICi;[w<'ezB}[pmJxej{]vmkX=I~B_;ampp$=KwX*iI@e<z3w}eT[+EJ>x~2g$}j
    w~5{H7hLZj>k%oa!#2o#3@H+o,s!~IAeI_aK@:!{'\='i-lAD=6p@$1Bv?zj$3_|?<HDEm3jrA@K
    pWJr#oKDPBXEp5lB'*ro;5{lxEDD?Gx1Hx5!-QRvxOkHpsJ@wmD*olA-3VVklVzkQUG>s-T=a[iK
    3&sinn}'lDU$+7CRsQ55Y~rT$*h@>!!XDW\?Y@Te+~D[Ao$$BJ_w=^,z?xmvOu5_U+k}k5?9"js1
    Ws,~=2]qp~E#DG!E}+-29zDz$4V_vD7AEURW-n*<UAsXV!sopD+HUe[#Dkk5*Yd@]Z5I=AJXD>GN
    t's,$\3TCrWUC=U<3*I,^WzJ*7YT<C3TnlDW-5vmHi[?-LEB5vm}UR~*A#IZ5n^EYKs!2Ju+vsI3
    +Q1\n#,2*7]YB@x{KAen=XIUYG7~eo{vO]H=-H[Dmsp#aAmAzZ}!3*CW1V3^w~QenOOQ7IBElIQz
    7#c9gK{{xdwT~]NtO?,1mH<mtmOC}GO?<?r'k1UC!TUl;wlr~ena$XYk+xv]*c#-xul}}pWjJ@+*
    i{C<BI1#YZsp-w75xx$\Ta]i!\PrrKYXVGi,k7KusK<cLB$\R8}<+U=33Xrrom,QHk<73GVJ]Xr-
    *z'Yu[1?B]\ZVQlu;u',=-2jYXL0v@p<X5[G^W'vrAZ>oUC]Cwji1e!1B1ABOol>eb~]il=E~-yV
    _w}vn_lkNjO+,,C#@C_\]=kI=xUX{R$zDD'nvMlKX5sD#lVYI]@IYkG-Y=j7HvekJ].#n]JAC#E9
    }x2J3O'D-[*#KV;_7vUR]~ZXO,Vsvj,,lT@m=fO*mp+awT3^pC~][sKR-[iwV#)LP'CQ5X,ia*{~
    l}_[-A<>Ce,I\7uvik{{wVY\x97wr[Ur?+KDLBx]*[s+!&s]B_7lV]}=>n,ETB[kQw$D\U';@$1,
    ,]=/\<jGY>{2o[X_*lIT5p=[NpazvjmUl@o'vGI3B_nO_wU$^bp=eWj'X[wl_$W_QX7:_Z=p}SZ]
    *10^b7\Z19/hQu@5'>,~8OU],8B>ppCCzIeK3!Bm~\xwUu$W1T&r<^A=Zer*{p}+Ar#Bjou:v'j@
    =O\Eym1DiW_1H[jQVdE-lsGm]J5X}]Z=7noT!!B\j\X<3m$n1*X<x,0@j]ZkG@Y-+*<kHE<l+U@w
    Y^j$vE5aOnJIJRE[++7lCu1g${H7]~ZH>Y~{e!w_+zpC_]aW^rRvH5i]^2zBWwC~oss\\<J]QKjV
    !_er$HAR-anz4jCVlD$Ks%?zC\[2W<0~j?';l7=1MldUQs2UEAK:oX-J@aT;|xGmku$R]ZHm^-Xn
    @G^>,=zC\=aXEINp{5},H=-8'aeKJBY[^i{R$w]QY>ZO8iT}k),YHr~8&rlnxZ*@B2B';=OX-{OA
    piRD?[E!;Y^_~u+BDKp]2[{!fd,@}J}KTV1zT\$Ciw)*sjj7\BEUzAnq0Ll~{wUOH*p?B<s*D@?X
    Go(UY<^vrDW_J{j#zIi7>\lHVapGUWzBxrYl13U*AT]e$GRBUnA[Uo>noBuORCI6{TK@p>@#NC}V
    wC;_'grTp'1oZY~B5rAXvea<uW1+<{Un22{o=^]al3~*rBZx\mw]ZUnXjamIwxT,QAd)Bplwx];x
    m5RZ,RWs'i>=GR_v4W-zir$;OJ{!!_k5WEKEkG*JR+=pQk^_QZ[^=iUB'j7ZXuvW#s+C;iB7HJOa
    Xvo<wo]TZJ}zp*R3{w_<nrA[{D51A$[DiQs1\7*;OnCYDD,3aIkT{'r\-'[*X;[5wRI2+X_zzI(l
    <;wU,?rzj2s\EX$7iCD\NT<aU]sTEG~u5*pR53XQa;[RTG<^-YTWWD!]RHa=ZpUY@zZa_gzT]n}^
    k>D3xTaeaOp+BK\Q,w}?zmaU-*+\TVXRTJ;HYmm=2I9NxE]i_5{}FaGpjr{[ZLo{XwQQ<3{z}pG@
    pwxW;!-O[m\pl,5Ow#Qu,1v5a2oI~3vK]2^@Jmw_*WmY\^VXaj>X-HzxAEl#\'XYxmYBBw~HlB#$
    R+^-7TTOm~n'}!o=+Y+VI#p@G-?1^-p=zu<R'AQk@7@Ge}-vBK7-r=--s=zl_]s'AGcWA2xNo}]_
    AHBYBKRmU7#;Vs;pN=6NWIYA25XG,#*Kjsz1;+7-B6]\J$)^C^*$'Z=W^5\/-5uQA=^{Y@l'Iwwp
    oQQGV1p;,s[*zneG"TG!<pD+aYupU,i;BTHC#27^oDzm3<VJY<EIOIz=?rEx-Bj?lUU^n?^Amra{
    ss(l2uk5G@CvOW@-7l2A=RV]R{{RC{uf"JHjiU.nO?*2GRRX_WuVZzXeYi<eE7=%B,~pdO}O1.op
    ZKB@$\zeu*eDvDYrZW4OXnT&'~_pj'OUa\~sasVx]$T?@EnoiV_~{X}R;R^rZr<u,_]TNmaU;B2s
    x#]#DH][pW[uQ?zE^\sl1XA\*J*uaueQz*rI{lWa$}{,>AVV-=Y}Y'E?UfK,QDorHz,kp}2}<Wl'
    kWxXRA3-xYTC5uC*@s1WK[jCx$V53T[K\JMC~lZCvCTV4j\Gpa'i<3]BJ1Yzx\G,ZvIaK8wUK7o:
    w7=;l-Wn#wz=DGA;^p>OE2}XU}Q7CuR5S1sT?=mV<T,X$wTZ>!C,pDU<=w_TevzO;HBC\7wGJ'ZZ
    lUaW7~sZKpjp=j>$W_[QB>jsVH'I^CwmDB\3sL3YAUlRr_CKru,~;oY]^>(oK_KbQjakDRE[<7v3
    D1H^uGe}7HmVo_Y3vZjiFJQ[+=rIi'1ICH7X1[e2V~Rwkpo5+F,0HHuzo,TrM=@}~D}2[l7=Wp]>
    T{GEZ?}H2#zH#d3r>pClH;^+^WIm!3qoujRZ5IOaRW-^3T1MlXB-K6r>oT{}AriB!k1<<~RHNVnQ
    #WA\J;[7V\1arCa]B-p<Zm{7]2+'2Bz-5lAqa'JImrl-pX>;oa[RC^Co~Blj}\2??Eza\G>=m$i[
    fVEVpH_vA]IZ3^=kpR@1Yv#CI{QGe&\?avPrG$Dvk\JU8YDJ]G=vX^]}}DR!>}E'$O;_W^J1l2^J
    C.2{2nERY^]w3GQjm{X$x3qU+1siv1rF;G<UR$Z]|,Qj1C2;k'=mlEmo3n\*A>wA$u.xkQ;R[voI
    e*},zeQ7ep]\pje{EAo^*QIs,2D*VOBV[k?'xUln<a=[1pR$*n@[Bk!eOWEN~1Y\n{>!XIO?RCA<
    PXltV~xw]l2Dp#~ReHR*ds=e3<{_T4giT@KNKe,1"_DQn_oG'V!{5J<__55i~=;7?m]u^\BUO{$I
    sl}an$>^#z<Uk$H1k,]?o\jx$ZH='Dso5EA]U6?wBD-\a7YIlZ*rvE<XY*jxwekCo>BY[@!95Y#>
    @sQEEG3TE<D*d&Vlpp!skxj\<}\jvstA]GE{s2*EZ]TaYn\Kz+H3vK[(se5G@wBO,1G3@on;*>5e
    \~S5i-mOw!eGB{]BHYO[5WnI>[+.,Z,?WvJ>^~rxOZwB[+eJYA'm7V]lm<!M~<xW*\!CX'#z1raH
    D#\p#1$~9AC*XX5*^${!pm>>nP*+;{EkA?__K]|q*uJp-5sT^Os^D}Q@#*u@AECAV}>l\]IpYygI
    \_Q_,JJ}}3pDzj=^DwUCVQ]lo{AITBQ}Qr#eK^2,<zpZp'^rWzo_#a7k[I2j}TXy}7k5}E?;2XWW
    YlT'I1*wV#>#W\$1{C]EX++<r~;xeB-Uo33W1$rGQ?RX~\#^#HUr3LMK5nBLx{JEoD]uVYZ*I@E{
    JAY25iY-x7[QwIm^a[jv'\wE6^pWK2T,DpQ,OD\sr1+$3W><x=<V\knllO!>-Y!$3a1Q7-G5\J=5
    VTVZ;ZD\2#v!O9&xiU<t2<{&oH{E=6%O,^UQQT?Z7au[={T:C<e!'r#[xia?]Z)}XI@$3I5ws,Zx
    {pI[ATW!Tm5I+,A3C#2%!]i;3R,[CTGr*[{_VjlzV=\HETWme_r><'Aw<11^]_p\e7Z[Dm_niTR7
    \\ADbpOvZYB$<>nQ#oV5vD*5}z&zs5?@jYn;XAsr=#ajKJvF@>7w\GJr*}i?=nj>xAaaBCj;a,<'
    @wEk{7[]a}OQ?\5Z1+2R#+5*5B?;RIXp~{J5d73KH\,o}&~Er\Stye@_ZCw$T>pQCxY=jVa;}l$8
    Dx+<|q6)[rGHuH+m^~a=K+{^Cl^luODJpR#Z=[C5>VpUH7Ka_wpH\^=^BZXaAvYk9dpVwa>}3mCi
    B]oDZDDZxAvj+-l1n@+j3KZ+yI~DV?,KzD3~Ga'{ny"~Q[{Gx{T,oo!KB#Ie@]p]!Q^GiK11KYKT
    YVWI~,m's+Uex7WRRK{;5\w'=~\a5]^TjOJ{wR_gKYH;y?IO;bw$dlQ!BT-np\-52n'AY_*7]vvv
    <Ew5DSi5?'}W1E%85=sEG<v\+TJZh*ju'?1@QaVBe}{E{BQi>T<^BZU-$Oe{-[nJVCU1VJriR/>$
    -R*;ue'o'EKos3UoKJZev7waVpjrk\2wo$oYG~HU3[]}*HioCi.(>-<'V^Ni}RCf,?VC\3TV1]D=
    @$;J,*pI3xsVOVO#*oJJa^};Iv{2lo+zOk\sjHI{I~rGtAzHakj}j2Vk1[es#^;nYjv{<lnIor,,
    UB<@Eo=_2<sJpu1^'2^=$K1pT<7Ys?A{[~$=Zz<>Eb=?,2G*+~N$@Z!V=jewH^VP+7sTm[~B*w'h
    ]jmziD>3,EEiGX7E+lUo?[15MYj;^YQ#5}'^z_x\T\'@n#+$@[@Aw_^Dwz[<XB_=x\2AveI>elEQ
    I,jl+mY$DrY*s\CB~y'#]W.D}iozT_u~D_w3r-G\BTIR!l[Gooe>5>sm];v+C\WA}lZtB>>;{a-\
    Z]{Ot}{GQC;;H!oOs]}QKK[Vp'Y3YG}<,jQD3;7o{l#+1'@+W>e11VTl-BB_,->ICwvrOTCQ5^UA
    R-X@7[TUrjDTxAa=n[.JOx3f*zZ^3\W>v5<D@{oG#HOJpr'D?OAYAE-e\pkYQiH<R=-;v}l-a$p@
    #rE^~l>-I'7z{aR-l{pGi',QrKRA_m-zp>_R]-n#+]iKT{mn{HJ37EwC<-ouQH;os[HJ):KDo'+1
    nDlX@V#saVhVIrYxwl}-']}^}?Ij;_x[?E?eJC#${7\7a!~5^I'~*xsOX>vp!3{r;!TaQJ1n,U-x
    <[1<]Qi^p1[VIa$j#}O{Y!X''zIbUreHC!,mH\'1r.#>KwDHYX\0vYjYwRQJ;XU2jQmw2rie#OU3
    _~Q=-\jjpa;'5}Ul""6vvxpaw=B+*1GUsw[[O<3O>>YVv7vb-l+])B74UjKE#_p*Z}A[=B$Vu,$i
    eY$TCz\X3]XG!QJ;MX*reaHu$wV-Y{_oIC_usrBC>N7Riawh/{zaEXE1v
`endprotected
//pragma protect end
`ifndef VH_FILE
`include "ddr3_controller.vh"
`endif
module `IP_MODULE_NAME(efx_ddr3)
(
input clk,
input core_clk,
input twd_clk,
input tdqss_clk,
input tac_clk,
input nrst,
output reset,
output cs,
output ras,
output cas,
output we,
output cke,
output [15:0]addr,
output [2:0]ba,
output odt,
output [`DRAM_GROUP-1'b1:0] o_dm_hi,
output [`DRAM_GROUP-1'b1:0] o_dm_lo,
input [`DRAM_GROUP-1'b1:0]i_dqs_hi,
input [`DRAM_GROUP-1'b1:0]i_dqs_lo,
input [`DRAM_GROUP-1'b1:0]i_dqs_n_hi,
input [`DRAM_GROUP-1'b1:0]i_dqs_n_lo,
output [`DRAM_GROUP-1'b1:0]o_dqs_hi,
output [`DRAM_GROUP-1'b1:0]o_dqs_lo,
output [`DRAM_GROUP-1'b1:0]o_dqs_n_hi,
output [`DRAM_GROUP-1'b1:0]o_dqs_n_lo,
output [`DRAM_GROUP-1'b1:0]o_dqs_oe,
output [`DRAM_GROUP-1'b1:0]o_dqs_n_oe,
input [`DRAM_WIDTH-1'b1:0] i_dq_hi,
input [`DRAM_WIDTH-1'b1:0] i_dq_lo,
output [`DRAM_WIDTH-1'b1:0] o_dq_hi,
output [`DRAM_WIDTH-1'b1:0] o_dq_lo,
output [`DRAM_WIDTH-1'b1:0] o_dq_oe,
output 						wr_busy,
input [`WFIFO_WIDTH-1'b1:0]	wr_data,
input [`DM_BIT_WIDTH-1'b1:0] wr_datamask,
input [31:0]				wr_addr,
input 						wr_en,
input						wr_addr_en,
output 						wr_ack,
output 						rd_busy,
input  [31:0] 				rd_addr,
input  						rd_addr_en,
input  						rd_en,
output [`WFIFO_WIDTH-1'b1:0]	rd_data,
output 						rd_valid,
output 						rd_ack,
output [2:0]shift,
output [4:0]shift_sel,
output shift_ena,
input cal_ena,
output cal_done,
output cal_pass,
output [6:0]cal_fail_log,
output [2:0]cal_shift_val
);
//pragma protect
//pragma protect begin
`protected

    MTI!#}}lIC<XEx<zD$,''EVnVYH'DP^1UT$]=i|*i=[lKQ[aDWOu7XVv3J[z^Aae=jOgEe1[}3$U
    1}GjT<X2rC2Qr>U=;l1G~G<1]Hz#~,Dl{<WY\A~$,KNk]lAJoX\OGr7\+x^I3eU;lrim+AryKzuY
    rRv]}wo>iA2I%ACAOl}*YokmDO?rl'UJAtUT[,j<_r7X\lNe1{HHOemuC>W+x~;\5J{aCBe}uwH~
    IBDr$!<piOj$oI\r~u#NyPFG|2O#ejv{UC-O7*E5@h'W\>XnvCz~u@v!$i7jzzT-\T{}{~yl5wpU
    v\[_mz-F]WjwY\?=Jl2*+TK=XwW2*ueE{OR><+<{TvuoCA;-DalV>Ur^YlQCZ'ZT8{_Uz7UHam*;
    kczRm3*@lrF<UAZ1xX!>v;}zOw}0mlrDjm>*Em$v*Dxxl@p_IKBv=\V1'JT#YlY{@D*p]^TeQ~=a
    m}$*P$nI_Kw7u^<r?'@1>_~sjKGsw#{UQ{]<~}Hsu^-^B[(a]TrO,<APABkQKUwati9pEZ[O^la7
    37>[51@xn\]'j7*lo]_2T{[~,jTj=Rza^D~[i+;!<V'J<m~#O'@!HX_<YGZ\e'[lmDXD>Ox{QU^:
    }&f+sGToC2[_m{^F1zVY5QV@,G112x[o-<\a{YaOHE3-pZHj(#RnaV,=E,p+jh+HZ#I}>@oOpjh]
    s3wT,Y!Q2up^@7@b9x,TarHrCO\AOZn5p75(8Yv@<Y$RYBZG*w9Tj}eF>xK]}m,zxJ~kQr2[AUw,
    -<W@VUIR~1QJM4gp^w_3p_K]?TJlwTWTUj~gX$9yA]>2Cw{={5mEnTTy\}TZ7kv\Fk<=^=^TT'1s
    o^V}a^?v5[<-O{{u~lCv7%7k2B*<$*7Y$m*xY@$OG~_+Y}Z*B<*D7BHnD5}jC7|kDkuUsJIxrl}i
    [Gk@VRXxH;<YO5#?1EDT'{TG}a!P+n!xY;{]5]^]'}]s9Iku-8[0UXxA/3vOKj<_i\iQ-laTGSY[
    URx\+56yC=;Ixa;w[zO*sAZOoa5O2pQ]sH-evsJxYzlWu[=zk\Zn!DOrzs\V]Bv,GT3a-7E<}'Kw
    p<xu,nM$oQrp!}{Q;5l[^?J97Q$wF#Qv^DBiv{UIav=>v3l+a|K>7Y,>sRr,X<ODksOCmQ~5<+A^
    An=+CBTAR}"45=[7EOQ<|9>TjW-RWUk5BsGD[n{'RnTC2A}ZDZ5{BGkn{IOH,W_+VGF[TA+Ct,<A
    Xl#>O;^@I\W~BB_]=[>,1;X3+}8Qp5A5i,[XA*K8sjj~j0;^*XtiX3A(rl<[NQ3au9{a+D^ro~X*
    v;^Q~7*a2mEO<jIu*2IIZGC}{zZDRoBR3Br!1Our2}+=eue1ZWH<lBz}<{QV]iQXr@[==#M:OvJx
    "}*l!}^VZA'{?[}*[wOko:3-=v\r33-jnRbI}]<4rG?TyE+{?\lxY\;uT,75Q1Vm*={1>Y[IJ<DA
    $OZ-'}EGD[3R1-Y1i'T,X4lsZ{7>7u*x[W^@rQV@K{=>jYz;zDfaB^?bGp[oWl7i^iAjo_;kQ~w\
    e{IAv$$'B!=]'npaC2o]57\zr}\I+wYjABi5=E#aE\vo;V*Wt[ZpKNeJEe}Qp,$=]5v]a-7[oz=@
    A#=,kZrjrZ90>aY-Z[[$gCU@*VxnY{5oj6xoO;zK_?j6aVr3!C@\TaWHXT5@i*G1HHKHDlUxH-Hp
    !Bpz_rD{)J5]wDWwsHe,rIp;;r~DR{G!^B]Bv3we5vS<Ia\GH5Yx}*-v+T1xr_H>wI3jJ}BepRua
    ^z-'Q_K1AAlp_jB&1eeoBXsm1[Q*p<<^C@$^EaI'i=\#$XaAs+j#Vl,ig:RAD@?aERwU''@*U2?_
    F=wmo7s>O)wz,B7<]_LY=r-V}^X~aB7xs#;Z5!UCL:iAmJwCTze5<azCHA;7k_^l<j[Z\z)aU\{]
    n;YWrox$QuRQ?D[#,RK)#HR@\xk_75=+^I~C<\1{7,_[73IRQK~m![3[ya5Tn=x~v7X=\[{aB-X<
    2>\>rEUp\kaB{ll=D2sO$~CJ+JI{v3GQ[JrHTia--sKz~aQE_'ZIjVZ_Bk=#C7^o]oz5?eQp=OWQ
    _2z\[1wQV*OOBj7DQjwwzXpT!}EETAo\K~1?C2n_+qpr;mV{$al;@=R#Ix<$2u!G~lG_sznz7Yye
    A;7Gks{1@]XzE5^v_r?iU{a^W-C1?=UBJJszn7E?[YuO<~?oll1kErC}>V=37\u@<GKz><wYn7pO
    <m[$Ulp15iAA[KWpY+ml_X>++}?,iC+xpx^pvj2x2~K}ZT*TEAX;=zvEJW,cYw1;;=RzuaA,IK{l
    ]xD,2=A#?oD2[x,Cj+*;;ox<&$Bp@qVj#wS!<wp7\X7l}~*U-Vl.QV?-r;'?WAxp?B?a\}z5q*nB
    +]?n<DVlCjLE?2\,-1GB7>#1YlR<]=k3Xm~|V'neKBA~piea}[[RAAXjv'{[7IpIh}~H;$[o;r@!
    p#UV7zm_5]Qj7As[x&@>uuH^&nGe<GJ]{H-J@mI_,]pwW+V7iD$#$sQ+uOZsDsA=e{zKx{E}<1a@
    W#AEC_l?]]H3[zj-mRD2@^!~2VpD'T^z+pjI_E>ex$}V!Rn]JaXRu6+o{ueD,#'*ZI_aCV}aI]v}
    @TxOJ#3e}n/+UBR#ST[pn(sCillH=W=XA$rC{BO#V[~=5T|7@Z#B;]v{Bm'GaE_{1}-Y\D]sgr<,
    E]B7k&AD<,mUA$L,}ea7kQ\b#Duux4K9j-H$C\}Dk-J2^{X^P_2a^,^arq7^u=[R*QIKll<w}!LV
    TBWCX],$r3D!sYE2a=?Tw~2Q?+JoKmz+}A]MOjO#]l}+Kn^](re_<f'3e3']~E5YsE\CoKsTl21+
    \@2n$Z'wE;1~o=$ZC_jO\QorOnK+lK_^V]{r{^UTKG!IY3+DBE}xu*-zroBkOC3RKvis!wepX71$
    Js@e@^_-JAV$~;6v[DRk-@OmOvR;1'#,=4T{J_?C!e1~[B_}BjY2]EU7A=$1=-Vu=;5+,-n]JVQ,
    Yn2}R$O5'sC#~QQmEox$nYaCA\|XBOmwYE}^ZW@(Q7_BvTR~vVe>V7m\reuz_}{W=8V[W!+G>?Y_
    A>OWo~,xUD^CTj":>}@olDn>RsBrkRzjXIl]<'?<@op!joQQ_{,-xH;{)k*je\Euxxvi@lU7<a_R
    T7\eDIEH##jB+ou~2rD\ORGmGJs}O,VT?KrR*z}+mU>1Qv3oCxWY-]?}u-U3k\+{C?nA]j!su3XI
    Uy$3s}jnCHYWEZJ<*B$jx\l1zDQ,J$,zsUxD@!z!j*su*lTlx~g#a^'j,!B<\lQUO=}nH52rUU<L
    nr?Bz\iZx{C3[U]I'^<uw\ps1H]2*'UZRG}~r<{@>rV}Ea*Z7R3k<'xZrK$ZwUwsVO;[YZ5$X$A[
    ^v}\,Y3U1f9[W3!~n;UJ$UoRH32Q8,!\$[D^=+su<iI{ppZ,~_12uYoX~8]2]-CR^T~}ku;A<U:#
    YEKp]piE*Y[}3'wQ_-!5@1,CsVu!UGu?emvBCpVBU>_\Eu$1]_VZ<C7REkQC@*lz.CZoUiD;Q[R2
    Tl!2QZ[p~D!7\[?[,^W;'2'allOri7eraQX1rb[u_'vk_+sWlo58rOBs,Vv=V?JAo+-+O{^Y{z-^
    B{GZX{Y5G^DeYVCk*IDj=#m$2_e^piR15;n2?[>5QmG>vIa@5YIlCE<'$WTCJn>If\2DjvsTI1Xa
    aEWsDe*}[p*<?-E}l|9?]spB@VT2{ooQCHKGJXE_wB2Ov-RC*HvW,5uGIK{A]Z13-J~BJ~Voe?r7
    B+CK>R$M}[>ey;lsHQ2Q>N$tVh)BI7_TYB#k[<C+=D_Rr}r!XCR/IH,jEUe;\#B1>U;}gTBiEz]x
    D@*Z7'OWwj5O#iwaUuG;Bj~~Gn7ri1-Hj|BsuC}2Qr}o]iHrY7om$,oO,>!+75?-Ci,+TnuBCK^B
    a=[7I[vEBK5$\u*ns$pQ,}nI]=]Gmx|2s1AFHlwx->IJjl]^QAA'kHnE_x'B@[@?bdIo2EN/}Vo;
    QV=J7+}r1I1{KI}=GeesCATp;rX!fwGk?@r>Wy{Gv7^rwJx,'15ym+>O*ClT{Q?XW}@1l={Brl]A
    JC']?\*H'V>>X{1+@l~3#OX^Vs++z7zJ#wWT|WorDw}\o\^3KQGB\3To$G?@rl@~a}s<3-B$DBCR
    Q+^^5q(/%m]G3>}+CtL\a<E^ZURA1*R_'\O8AO!Ri^+]:$,]V:5Iae&?a{1WE{!M+{75<X]$CWY}
    EIZ^?lGDDVV=e=+Hn*yLp\5>_Ga~^l{j&MR?l5V^ok~Y>!O#BI'=jzKa><v<Ru5vAuwID^l4a}lp
    Y+271IaGrx{v2TI@(aYmx}B$@ZzY}a'{kn{Ju*m21UlJKf~p=BCz!IyAEjYiOW'Vn}v^;Y}>z7v-
    TJ$&mzZ~eU^\7o^#xCmm,[ZX-+Qk)L<QvwBzK(.=^U$L*?$IVYW2#wJJz\Wlw$ZuezKxTOlVir3+
    kR~~3C[]p;$\YBO?=3zKxWmzr]nlOil~mHYBm5Yx2C^'@\jk?E~]b\V#O[CwelW]E3I*'*;2Y+Dw
    7*>[lw*\-**n@l}XTvnl@AA1V1^Bv8mpT'tEK*xAO]U{wD{MX\**==A<Z5<avnuo]Ov+Resn;[xG
    *k7XHE7a*<.-+@>x2^_BCXVJDvHv?QzqEz_ucR2DX2<7lgBC#+GZ[;QO-?^I{[;>X5/!*1nf&}Js
    XKnJ\$i^xjpm^5Q'UJDJ@c}g}7\R}KpTD?}UI5Qv}Y#^$?*u2sz3iUp*RuC!e<E^R>-o(?e!pIKX
    <*v{H^k;^v=>oI*D^aanon'$22T=pBn!YrC1su+Io~YsAKCEZB']<<XT[V#<sY^D+)M-s'!Yn<!@
    \VxOLw5lJ-Gv}pw}X*Vuj?E*6Ci+u?jQvve>T,!me;TT3u5]o~Xs}=!\l.5<Brl*@ei<A^M;'Q~]
    3z{ju*ZRK>78B_jr)Iiu}<A,#C7_$O%x5#*e#eQ<<E}#1-1?<CCu}?Axv~T6InnC*=*e5}-wx#>5
    Z}V,fW$XsUl@-\$A''R5}Gxl2Q@@uop$?3TX2QG;puezCoroe+H!ZiI+1@'*$-+{zprEYe2Ci$sR
    OMpHY1?\-;o<5a#1Z^{RkRe5#pDOJjo}Q#HX,Gnv!$ZEo@UpA,-X}z<r2vLmAJT3<XmduaZ?5'QK
    m5nz/j?];?<*pm>XZv\DRHXRwG^-2Da\Q$u]Y2l=[!IJU~B$i@*QT3HjoRR{;V'RY!HjaB_}HIu{
    5?7eZsn>*xa]7iCC!**<#9Ei!apUD7s=,>JEpQ'a2*Gm~-#EZnQQ<H!BD23RiTPvG\khCto{'Z'W
    $Tzw}C~t#Oi*[=V{r]{lCTKXaV-24-$_H_}_wY-]W}mK*eD3@C'H~>rkXvs-<snS\dlw1oWHU$]{
    {-B{l@GZ'v,{DoIZaRZ-x~ZOTYm*!u{}>~\i]Bo+}IA+XJvH]7K7{e1_2D<&F3G,O1$,s5o-UOr,
    {\5KUJTOB3Dpj!,m>D\ov#aYZ7V5uCeWxpo/LZ^=oawQ'R]{~?R,'D=2_f;B{vKT1a*O-=(ETVmr
    K'r?X5KuC7DI@UU]\,#93*@{wx<lj?;5Zo#T+,-v$+Js
`endprotected
//pragma protect end
//pragma protect
//pragma protect begin
`protected

    MTI!#>V,jk*DCo2rQ>=wU@[nl]uuBpGVCjvjs|)H<R"@U<am$'Oi\;<$tN4ET@okxo$a'<rQ2WjJ
    ]J]Q-Cs~{BBY6+1$'Q,AmOoXA31,['>Kj]7ox_u@]a{C~=Gzn[jImz<]slx{KRa=_[<,sOuT7?nR
    [p@!?c{_1*oCkRE1*v7\zX&eIR~+DK*"B?vEmpY<Ygx+=WYn;a}ZTQ1Z+ziszx{&I?[[7@;op#OD
    U<+u\ku}g$;{u$mWWsVs]cr3TD$Qj2epOs53z$jAYpD?VYE8r[7!S~-e>uD3W'Cr]jTjl#{-~]aA
    Z?<BjE7[oqBa\5<oUxXTZKC$GkSp{+3Q#=}]#D@l}AooTI{szx_2EUa[J=n$lH^LeT37}XGDckw!
    QUYA;MGsiC~wX'DnG,7#3z]e\'\Evi-<lz+\1}+,@pojC_*;*o@5^neO?R~='rz,e78uzV\BBRjO
    v1{zWwXj=X?Oo<ZkAl*!+-B>IJ1IZCjo{YK6sAxwS^ko<BDxk-'Rn=_;3AnA<DYvYRlX{H]C^;TK
    A.pnK-^R^]Qi<p'{V*uTEpYwnZu1}s[#2#(B[H$x2}}m^iu}Y??$=BwbMD'YDOeD{}!7V+BW}jYx
    ~=#$5UoQ*[&O;oVl+~JEk<JU^UrI;Rju\Tp^1a}*2RJoH{mIEeozwwBv-eX1x}Z$OE;#$B1ix~;@
    Y#*2Ee3KxVX@jJ^#r=iBZCu^J=\E$1}Z=JUK'H<w}jTCV-I#-OvJH=jy3aup%t\B7vJ^e[*;@YzQ
    DX,^3#u]^OAI@w*jW-OBkwo+5=iDA'aGr,VW$pv]x{5W\ph@>;l6Y0s*5RxG*kz'B~looi]^?,#\
    7$_Q<5EADu=7jJ$$H5OlD-x~,RlDZmTaOB_;@z;vp~B"[RzKdK+$D?x<I7s'#xoYWBJBjSea1R_Q
    #ufk-5-p@=?QiD%.GIDD]VQ;O|Vi,[]v\+MH7T2uOYx$*!YmXI}A*oC!*Bunr,E<X]K$lY\}A[=[
    ,pjvuVDN$0p+G<l3$~_roClCk7\v[Q_sEEV87zU=_U=G4v1juL>e[e2YJ*Ka$^s\Ka\1-@mnx+pb
    {O3J-13nRGiKJXK''*;[5J+x^><G<E7=Z*?TOm7'Yk7\-{aW1Zjrhwr5\nq[2_?J}=B5\Z\{j<wH
    ]u{*7?uJXjx3^mn.&5eW+$Dm>*J[U*ll{HBluaT03TXk/7DV3!Y\!&Ee^Ta7!'aI}]W'rkiG'ua{
    ,U<j+zeEoV$7\72<HQ?T_$;jAVz#Z7k<5YEHW>l3-YaaAsa'R3ae\m=JA5x2<W5!>!O#7}>D{,yx
    Y\woX1paXB3YI<#As_7ioW1TaaZ;eR=Aa}iuxTumzQ}wTnHDm*2Xn^J1x$~NuxRxDp-,x"ID\KQv
    >@sRzIXBn~#wl^T[{5z>A<IiWvOEVm^Rza*;rn1IWn#Ta]YV7\I+W#$,AsQ{XsI-I;ovr7vTJ[mE
    Q{u=\j_n3}V-K{U-I-pm^p}OvUE[el=_jDH\oxVk<jPXrX![q}-2IVkxAw=Qou=u'3oHXEH}$NA\
    }<uB?7!G[rI2'^^^j$+$1,D-,jxQ{#xYmj5$\n;1}jG@25rY2_IW}r>eGk7*js^}3W/**mBT{^2]
    !5k8ls}]xC75EB-Vq'[\kGa8ozVT;+;~CHTI6R;mWil7G3pjQ2AsTlJ-?ET-,5A7C$mv,vi52^3$
    -2D3;DC*ky7Y!!2opiT_nrK5?E;xJ=eDaa1lx{.hkv-xrpB$R'z{naE;~A~*{a>WCC~H3}'@l=i'
    UBH_SzC<Tm^Cxlz]7@CnTD~Rj^r!r]\3e9W7W>]$-<r3uTm+7u}[ZC${n\\s3X+]O7w}Vs@C-V*~
    ~1uO!]zi2\8no>I}mJuFQx<eCx,{e7k;'5\>4tC7}=k-Ae^I2-l*@I_ia@\ck]akC'XH5[{pQ--Y
    sTvn*!}sfVY[^l#;!Oj\eOJHu]Rv?2<@u2HKxBV[~lm]\AAuZ^$@[[J2-#GVYQ=-1Bv_?uwxo\x!
    z]WDzv[ozMQ*AoQlGv~RWr;l>3\1sVX]*!3aGkq>-r7DsB?uEp+uV]CEU7uvZunozoYHxWZzEk*m
    Ij5*B<#e^zr[=n_0a\mE~-R@l#$'CIDWQ.$#H@p;rs_VjI@+1V,o{Jn-BRv><[C4J+*nY^{-Av},
    joEO!DH{Zare">,$aYs#+Y}+^j,[u.5^3}7Z\z]pWQ+X321?\[Qm2^oE>#5i
`endprotected
//pragma protect end
`ifndef VH_FILE
`include "ddr3_controller.vh"
`endif
//pragma protect
//pragma protect begin
`protected

    MTI!#[BW3p\\ElB=KOXI@CC\uK$fv@vCYv2DNE?t7#[@DNe,'lalGC"U[A$py[BT_~X'p$K2Qo?n
    O:X<+2U{){Ck;G$k\s{ErsSKwJUz^;}3[eHoU~XAlz@=k^^<[@BEe<oHE\j7vKve;}+IZ'3u]+}\
    Z;uzd~,UUHUVJ+l$_{X<]homj*x{~I$vX<KwCTDQ+vnCUD3X\#NHoTsBG{zZ=e3He{I0"K[oZ;j$
    BR,Gm7_}[aBRHDkp?\BB![@YnIm11OGO=+U$nB"[}XrTRz=sS2'+H_l#YADv][nwBht}\IUHD'AT
    Bv@EjXz"GZAuX}vB#asAl2voduo@XG_VKGXvke^1Al~ano5sk,*3G5\1B1V-_FET~>ms=puOVlED
    31osQlvwTv8C;_i<YW;Fe3Gl}zX$SH5W2u,rw):@xHTJXXxQDWG[>sC,z3U]_!RszEBIT+,IkWC?
    D#]u,t-BBO-U$zeWjp=De}r>a5vnxA}Jp<H'K^G\Hen'!zAzs{$Owrel^X]Il+w]iYY~,Y3{$[A[
    XzDsH=rDio__kZ^ju}6B!vlIEQK7K@]lVV*-wpX@vCl~V<Z}oDsYB1]7_]K><wBf)!rOv_iGDT[m
    eH5,xVYv\)L[ATXe$Uasz[TI![3Il#mj{aZ3*\r}B=VL|&[BTue#2ulB<D?DYm~sX'OBi@^Y^~[!
    }x,},<jizRaaCH?U*a*Cz^-RT]CI@1:p#v*Q^B\(qp~rO~lj_up1i_TO[-*I}Bzoi-Nyx-wATrr=
    :=Q-w$EW-7O^rM=w{!QR![E@@5r\*=HYTezns[q[D'KOs*'
`endprotected
//pragma protect end
//pragma protect
//pragma protect begin
`protected

    MTI!#q_TDl:*EC<V[~=2-J,d'^'DP^1UT72t|*?!["BevY>1U{#H;2$E:\@]_r\3Q=UW<BOp*a[#
    kl2uX>YT}aap<+1$'Q,AmOoXA31,['>Kjr:eD^@LTl~!,C>Y1+B?!{}u:7Jps|4xU{XnwoQGVH]7
    rGup2HvHjz+[,>11!a>ND\7O~<D$N[UT1I=77p!^@=XA3BnmJ@,v7Ia-TlwXj='~xD5XeO3Ri5\]
    _^V+k{[;vY3J};sO}$7vuFJo,jjJT\/-O-D!{D]pd%tUa3Yin{,[+~HXopG}<<J<h]EbKow'Apk#
    Om;<E*}{dEn2oH=EDf$QrzI~o$W.}V32GV@-=9uUDaC#KpO]U#Zsj>O^_3rIJ=@XV}e\_C_k'3Y~
    {p}\$v<U[lBI>;1C*HD'HUQspzp2ZxV_lOO']nRW]#x=>j1xE,XRe\O1j^X[+C5J^7V1UO~HW@?Q
    ?J,*#Z1Xw${az#Vo5xUpx?H7##gzj@HGx[[Fq_UxZaR<uH1XlxrkQ1_#2}zlZH]fvY<3msmvx>Ok
    ~O}Jlpl7!*W[[CGZVQ#5vQBK#a}<!e7x2j5KP'rx''z7]x5]C''+vI5sJEnwJ-{e$WQ?obhfT,<v
    IZ5KWe_upV-Q=*ivL%D&IDpUlzlQCk;'15;?I!w@u[OYSC7Wr1x>$o2mR"Y-eDIl{=Z,_J}jr=-O
    JOvjk,R'loQCY]|nQYA2B3_152DC1m3z1ZR}H5vsr@D&iour7A{$CR=]*TJkH\i-y'r7axz>Be{j
    ,l#1~sIAuj$m,g)H}JVw$w;ZaBl]ZERkp+-lwmH/lQH<nOp],E>52rQ@*p[^j#>-dhv2op5<+'1H
    up/$I32oH{E!VY<{Y;D1u7m,!7iO"TX1<H7>7i$J+_(X}p<?n1G\HH_{H^H<$<]}-CmG<2J2[D~_
    A,r|DOVWtG{Ej!'_>JX$j,p@$iI'{#1JQjO>maDQsQ~2ZI!7srT^@fdk(it*W+{W,,'5i5=r1?]Y
    U=vWTo~
`endprotected
//pragma protect end
//pragma protect
//pragma protect begin
`protected

    MTI!#&c}a3Q_\l2E#ajUx;eO7eDzD2Z#jk3Vo?uDM|Q!aVIGWO$xj2G?$x?_<Tne~;vmXC7kQ2_E
    }H<TZnp;,+|EfkQ'Be-e]iXa[zx^QI}VCXvopoz!DN@'}#$e[AeUWURv#~dQi_#s>Eop?]HIW,BW
    '1_we<}Y_]VR}['TskuKUHOj_;wC$A_X=}s?C@UVQZG=5Dk\l^Bj+}^H-<usxXu_<,#G*1}Nzxu*
    mpB<'!pmlE7iAnvV]J]OL1UxQh2Vo#Y\euI?5?];-QxE;2?H->r\Iz-\sBJa,I=T^}YO*WiYz.Qn
    +!{Tj+;_<ne^R^2Y+.*?vE_H[s=Y]$ICDk'#<5kwU[7D]k1?,p@$UeFZEOx1>>wpRTr+UGJ*3j''
    _[WJvQ<;XU~~wZxB\E?V=GlG9^l*#G+^^NEY*+=(<-7[.EH$$V^v--5kGRx1'Y@[JQD[J,>*Qon=
    X>Di}~B13y[JBKiT~I#o+u1+=-0V$3Yz_2a__U!B-HmekurQZ}k=!DmiRUzY;_H[i]l1x!7\aZ,t
    ,Xne=iG*R7X,Z{_}sIij<+]#_i<3KUQ,bqcI-IEFm5@'"2=iD<$$eXYQ2Vjn^=H<lD=rA1IkZ!ps
    K3^l?2xTEYJ{n3ECVVh%9Rn*Ee2*7]2Y[O\T@1zT3!{p}CwYuG~Xz}m*z{rkw'YU@mvv;FcxjZnB
    <'*
`endprotected
//pragma protect end
//pragma protect
//pragma protect begin
`protected

    MTI!#=Z5@CG[Doa{=H-_ui-JU'W>Ra7UZ|*Y[[l~*7|"B$mD,,_<VHWr;*V[1~UD]^CO[E2U3=R*
    s*G@fV-ns~{BBY6+1$'Q,AmOoXA31,['>KjrBj'_@-]Tl~nI^DU=V#m[opT^5^B?wpH6iCIU1-ev
    B1iZ;OmBx7K*@E[7Hzja@UE;AVUE)f~{'TvX<[=G?,X7h%!E#ZXX32lH\,NxQ\51^+xOE?=GGT<D
    {pkk<l1B_m*#D13RA!!}VA}$@G<Bj*TCHW5fD=s_z+HD2Eisxpn\oHJ}a}BIaGuJ@Q\o].mIz^{V
    BE%l\Zs~sr%e>]v1>\^$B{^J5@^l-WW1mV[kjknu+^i!5rv=^+Is[,}ao{Y]#W=x<7]#Y|Y+@r3j
    DaFxQ#JeGv<<1{<CiC[Y7KXezY^Xlk?Ar;lpX2w[Wp_>+ArGl{RXj@e!e$CK$a,]<p7@&jHj$TGz
    \jrC@7Z'_*spImVripK$!Z<{*jA@kov*WvO}{{YE~qF,ZuRt31ZIM{UA$F,rujC@55uxI-;ps@7k
    vVv^1xlm~UQ_2H\\1nI~son>@r7KY];_\IE_z{BjT;O_}33H\UxU2AzjIknos{*Z=x]}Q![w=+v-
    z^U$;>^=~vsHDmU^YZRv$W+o<VB-,JQ],U^*|CB*s*lVuHEHG}~o,=15w=]_a-CQWO#HCrxZ7zu]
    #5}<<-n3aT^{nO\l==?$>V?H5r'ljY!<]2E*[r~EE2[531UT+s\W[IWDYGa\Rz7
`endprotected
//pragma protect end
//pragma protect
//pragma protect begin
`protected

    MTI!#QJAHvDU_w\r}qoA5R1mw[5CRa>D=3aI9PIORi'i3QRfQxz'9yeURQy,!p~mQ*!uYi<YlwEs
    +nZ@aQxvjk}]irz!w$wIi@DFzx^QI}VCXvsQV5T3N)V#A2Y$^!]^l\;Am^V#zKR,G,w]nHL}#=k-
    +Ap=\!uk_$n=<OCDJ<<FqhkaHre@{7G5u<*YrDz*w5IawUA$i'++-$j$~\#=]-@jmU7oU@7BOkz$
    1YV2$O^z;^}iuG9I_\A7+e^To-3^G++;<-x[u@oFXo[Z@NeaJzRD[XKn5$=#@$}>[nI_7_|DIDAC
    EJ'\=V2VivGIE7x*'2zyYJT2fGj3rk=o+C2>lUs@v>REvRJU$A5v$Trn'ajEpksQ~x#7J}vpeY[<
    [*-B@mT2A5nG]i|Nx^o[>T^zYDw2'V_X$jRB^/#r='}ei}'U-?,RKO_rvGKz>{q3=v['zJJ$\\=A
    C@;eo?BOwWon>QUvj{Qzx1zQ5RkIzV^JD@3L?vABv=_!DEmI?aV'Ua]!IG#2QGJ>i[]E|AY13W6E
    +I*&iw{]}mZOXDmKceskJvpB~Qmv@B>vz*[+BJw;@uT=Gi]$G}apv)%iEEVrEJ$)KD#nv^(';!m?
    'QW$}{,;Yu+^--O<5?Dx'p~7;*m]zXH}KJz>vvZ5i5[]RV]2\V~AH]7?QmoTrEnK>HXoj@G,uX,W
    ]\~Y@,W,QsXfe3r2X7#k?^Tv~{>2~'@7+rk]>'n,L&t*n[DL5<@u35wA>1}<H7=pA']Uwjw@}eiD
    1H-5KI2Ca7J];<[={|;a7egM{BOHOExT'#,pfr2_}FEJ;Wr^5eK7T;s+W[I~aG{eH#Yi
`endprotected
//pragma protect end
