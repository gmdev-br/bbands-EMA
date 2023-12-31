//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "© GM, 2020, 2021, 2022, 2023"
#property description "Bollinger bands - EMA"
#property indicator_chart_window
#property indicator_buffers 49
#property indicator_plots   49

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum enMaTypes {
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input ENUM_TIMEFRAMES                        Timeframe = PERIOD_CURRENT;                           // Timeframe
input int                                    inpPeriods    = 240;           // Bollinger bands period
input enMaTypes                              inpMaMethod   = ma_ema;       // Bands median average method
input ENUM_APPLIED_PRICE                     inpPrice      = PRICE_CLOSE;  // Price
input double                                 inpDeviations = 0.25;          // Bollinger bands deviations
input int                                    nbandas = 24;
input int                                    offset = 0;
input double                                 fator_reducao = 0.25;

input color                                  colorUp = clrOrangeRed;
input color                                  colorMid = clrYellow;
input color                                  colorDown = clrLimeGreen;
input double                                 larguraBandas = 1;
input bool                                   useTimer = true;
input int                                    WaitMilliseconds                    = 1000;           // Timer (milliseconds) for recalculation
bool                                         debug = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _lastOK = false;
int periodos;
int limit = 0;

double bufferUp1[], bufferUp2[], bufferUp3[], bufferUp4[], bufferUp5[], bufferUp6[];
double bufferUp7[], bufferUp8[], bufferUp9[], bufferUp10[], bufferUp11[], bufferUp12[];
double bufferUp13[], bufferUp14[], bufferUp15[], bufferUp16[], bufferUp17[], bufferUp18[];
double bufferUp19[], bufferUp20[], bufferUp21[], bufferUp22[], bufferUp23[], bufferUp24[];
double bufferDn1[], bufferDn2[], bufferDn3[], bufferDn4[], bufferDn5[], bufferDn6[];
double bufferDn7[], bufferDn8[], bufferDn9[], bufferDn10[], bufferDn11[], bufferDn12[];
double bufferDn13[], bufferDn14[], bufferDn15[], bufferDn16[], bufferDn17[], bufferDn18[];
double bufferDn19[], bufferDn20[], bufferDn21[], bufferDn22[], bufferDn23[], bufferDn24[];
double bufferMe[];

double arrayHigh[], arrayLow[], arrayOpen[], arrayClose[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   SetIndexBuffer(0, bufferUp1, INDICATOR_DATA);
   SetIndexBuffer(1, bufferUp2, INDICATOR_DATA);
   SetIndexBuffer(2, bufferUp3, INDICATOR_DATA);
   SetIndexBuffer(3, bufferUp4, INDICATOR_DATA);
   SetIndexBuffer(4, bufferUp5, INDICATOR_DATA);
   SetIndexBuffer(5, bufferUp6, INDICATOR_DATA);
   SetIndexBuffer(6, bufferUp7, INDICATOR_DATA);
   SetIndexBuffer(7, bufferUp8, INDICATOR_DATA);
   SetIndexBuffer(8, bufferUp9, INDICATOR_DATA);
   SetIndexBuffer(9, bufferUp10, INDICATOR_DATA);
   SetIndexBuffer(10, bufferUp11, INDICATOR_DATA);
   SetIndexBuffer(11, bufferUp12, INDICATOR_DATA);
   SetIndexBuffer(12, bufferUp13, INDICATOR_DATA);
   SetIndexBuffer(13, bufferUp14, INDICATOR_DATA);
   SetIndexBuffer(14, bufferUp15, INDICATOR_DATA);
   SetIndexBuffer(15, bufferUp16, INDICATOR_DATA);
   SetIndexBuffer(16, bufferUp17, INDICATOR_DATA);
   SetIndexBuffer(17, bufferUp18, INDICATOR_DATA);
   SetIndexBuffer(18, bufferUp19, INDICATOR_DATA);
   SetIndexBuffer(19, bufferUp20, INDICATOR_DATA);
   SetIndexBuffer(20, bufferUp21, INDICATOR_DATA);
   SetIndexBuffer(21, bufferUp22, INDICATOR_DATA);
   SetIndexBuffer(22, bufferUp23, INDICATOR_DATA);
   SetIndexBuffer(23, bufferUp24, INDICATOR_DATA);

   SetIndexBuffer(24, bufferMe, INDICATOR_DATA);

   SetIndexBuffer(25, bufferDn1, INDICATOR_DATA);
   SetIndexBuffer(26, bufferDn2, INDICATOR_DATA);
   SetIndexBuffer(27, bufferDn3, INDICATOR_DATA);
   SetIndexBuffer(28, bufferDn4, INDICATOR_DATA);
   SetIndexBuffer(29, bufferDn5, INDICATOR_DATA);
   SetIndexBuffer(30, bufferDn6, INDICATOR_DATA);
   SetIndexBuffer(31, bufferDn7, INDICATOR_DATA);
   SetIndexBuffer(32, bufferDn8, INDICATOR_DATA);
   SetIndexBuffer(33, bufferDn9, INDICATOR_DATA);
   SetIndexBuffer(34, bufferDn10, INDICATOR_DATA);
   SetIndexBuffer(35, bufferDn11, INDICATOR_DATA);
   SetIndexBuffer(36, bufferDn12, INDICATOR_DATA);
   SetIndexBuffer(37, bufferDn13, INDICATOR_DATA);
   SetIndexBuffer(38, bufferDn14, INDICATOR_DATA);
   SetIndexBuffer(39, bufferDn15, INDICATOR_DATA);
   SetIndexBuffer(40, bufferDn16, INDICATOR_DATA);
   SetIndexBuffer(41, bufferDn17, INDICATOR_DATA);
   SetIndexBuffer(42, bufferDn18, INDICATOR_DATA);
   SetIndexBuffer(43, bufferDn19, INDICATOR_DATA);
   SetIndexBuffer(44, bufferDn20, INDICATOR_DATA);
   SetIndexBuffer(45, bufferDn21, INDICATOR_DATA);
   SetIndexBuffer(46, bufferDn22, INDICATOR_DATA);
   SetIndexBuffer(47, bufferDn23, INDICATOR_DATA);
   SetIndexBuffer(48, bufferDn24, INDICATOR_DATA);

   for (int i = 0; i <= 23; i++) {
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0);
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetString(i, PLOT_LABEL, "Banda superior");
      PlotIndexSetInteger(i, PLOT_LINE_WIDTH, larguraBandas);
      PlotIndexSetInteger(i, PLOT_LINE_COLOR, colorUp);
   }

   int i = 24;
   PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(i, PLOT_LABEL, "Média " + inpPeriods);
   PlotIndexSetInteger(i, PLOT_LINE_WIDTH, 3);
   PlotIndexSetInteger(i, PLOT_LINE_COLOR, colorMid);

   for (int i = 25; i <= 48; i++) {
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0);
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetString(i, PLOT_LABEL, "Banda inferior");
      PlotIndexSetInteger(i, PLOT_LINE_WIDTH, larguraBandas);
      PlotIndexSetInteger(i, PLOT_LINE_COLOR, colorDown);
   }

   periodos = inpPeriods;

   if (useTimer) {
      _updateTimer = new MillisecondTimer(WaitMilliseconds, false);
      _lastOK = false;
      EventSetMillisecondTimer(WaitMilliseconds);
   }

   return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {

   delete(_updateTimer);

   return;
}

double price;
double deviation;
int CalcBars;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Update() {

   int totalRates = SeriesInfoInteger(_Symbol, Timeframe, SERIES_BARS_COUNT);

   CalcBars = periodos;

   if (CalcBars >= totalRates)
      CalcBars = totalRates;

   limit = (1 - fator_reducao) * CalcBars;

   ArrayInitialize(bufferMe, 0);
   ArrayInitialize(bufferUp1, 0);
   ArrayInitialize(bufferUp2, 0);
   ArrayInitialize(bufferUp3, 0);
   ArrayInitialize(bufferUp4, 0);
   ArrayInitialize(bufferUp5, 0);
   ArrayInitialize(bufferUp6, 0);
   ArrayInitialize(bufferUp7, 0);
   ArrayInitialize(bufferUp8, 0);
   ArrayInitialize(bufferUp9, 0);
   ArrayInitialize(bufferUp10, 0);
   ArrayInitialize(bufferUp11, 0);
   ArrayInitialize(bufferUp12, 0);
   ArrayInitialize(bufferUp13, 0);
   ArrayInitialize(bufferUp14, 0);
   ArrayInitialize(bufferUp15, 0);
   ArrayInitialize(bufferUp16, 0);
   ArrayInitialize(bufferUp17, 0);
   ArrayInitialize(bufferUp18, 0);
   ArrayInitialize(bufferUp19, 0);
   ArrayInitialize(bufferUp20, 0);
   ArrayInitialize(bufferUp21, 0);
   ArrayInitialize(bufferUp22, 0);
   ArrayInitialize(bufferUp23, 0);
   ArrayInitialize(bufferUp24, 0);

   ArrayInitialize(bufferDn1, 0);
   ArrayInitialize(bufferDn2, 0);
   ArrayInitialize(bufferDn3, 0);
   ArrayInitialize(bufferDn4, 0);
   ArrayInitialize(bufferDn5, 0);
   ArrayInitialize(bufferDn6, 0);
   ArrayInitialize(bufferDn7, 0);
   ArrayInitialize(bufferDn8, 0);
   ArrayInitialize(bufferDn9, 0);
   ArrayInitialize(bufferDn10, 0);
   ArrayInitialize(bufferDn11, 0);
   ArrayInitialize(bufferDn12, 0);
   ArrayInitialize(bufferDn13, 0);
   ArrayInitialize(bufferDn14, 0);
   ArrayInitialize(bufferDn15, 0);
   ArrayInitialize(bufferDn16, 0);
   ArrayInitialize(bufferDn17, 0);
   ArrayInitialize(bufferDn18, 0);
   ArrayInitialize(bufferDn19, 0);
   ArrayInitialize(bufferDn20, 0);
   ArrayInitialize(bufferDn21, 0);
   ArrayInitialize(bufferDn22, 0);
   ArrayInitialize(bufferDn23, 0);
   ArrayInitialize(bufferDn24, 0);

   if (nbandas < 24) ArrayFree(bufferUp24);
   if (nbandas < 24) ArrayFree(bufferDn24);
   if (nbandas < 23) ArrayFree(bufferUp23);
   if (nbandas < 23) ArrayFree(bufferDn23);
   if (nbandas < 22) ArrayFree(bufferUp22);
   if (nbandas < 22) ArrayFree(bufferDn22);
   if (nbandas < 21) ArrayFree(bufferUp21);
   if (nbandas < 21) ArrayFree(bufferDn21);
   if (nbandas < 20) ArrayFree(bufferUp20);
   if (nbandas < 20) ArrayFree(bufferDn20);
   if (nbandas < 19) ArrayFree(bufferUp19);
   if (nbandas < 19) ArrayFree(bufferDn19);
   if (nbandas < 18) ArrayFree(bufferUp18);
   if (nbandas < 18) ArrayFree(bufferDn18);
   if (nbandas < 17) ArrayFree(bufferUp17);
   if (nbandas < 17) ArrayFree(bufferDn17);
   if (nbandas < 16) ArrayFree(bufferUp16);
   if (nbandas < 16) ArrayFree(bufferDn16);
   if (nbandas < 15) ArrayFree(bufferUp15);
   if (nbandas < 15) ArrayFree(bufferDn15);
   if (nbandas < 14) ArrayFree(bufferUp14);
   if (nbandas < 14) ArrayFree(bufferDn14);
   if (nbandas < 13) ArrayFree(bufferUp13);
   if (nbandas < 13) ArrayFree(bufferDn13);
   if (nbandas < 12) ArrayFree(bufferUp12);
   if (nbandas < 12) ArrayFree(bufferDn12);
   if (nbandas < 11) ArrayFree(bufferUp11);
   if (nbandas < 11) ArrayFree(bufferDn11);
   if (nbandas < 10) ArrayFree(bufferUp10);
   if (nbandas < 10) ArrayFree(bufferDn10);
   if (nbandas < 9) ArrayFree(bufferUp9);
   if (nbandas < 9) ArrayFree(bufferDn9);
   if (nbandas < 8) ArrayFree(bufferUp8);
   if (nbandas < 8) ArrayFree(bufferDn8);
   if (nbandas < 7) ArrayFree(bufferUp7);
   if (nbandas < 7) ArrayFree(bufferDn7);
   if (nbandas < 6) ArrayFree(bufferUp6);
   if (nbandas < 6) ArrayFree(bufferDn6);
   if (nbandas < 5) ArrayFree(bufferUp5);
   if (nbandas < 5) ArrayFree(bufferDn5);
   if (nbandas < 4) ArrayFree(bufferUp4);
   if (nbandas < 4) ArrayFree(bufferDn4);
   if (nbandas < 3) ArrayFree(bufferUp3);
   if (nbandas < 3) ArrayFree(bufferDn3);
   if (nbandas < 2) ArrayFree(bufferUp2);
   if (nbandas < 2) ArrayFree(bufferDn2);
   if (nbandas < 1) ArrayFree(bufferUp1);
   if (nbandas < 1) ArrayFree(bufferDn1);



   int highCount = CopyHigh(_Symbol, Timeframe, 0, totalRates, arrayHigh);
   highCount = CopyLow(_Symbol, Timeframe, 0, totalRates, arrayLow);
   highCount = CopyOpen(_Symbol, Timeframe, 0, totalRates, arrayOpen);
   highCount = CopyClose(_Symbol, Timeframe, 0, totalRates, arrayClose);

//ArrayReverse(arrayOpen);
//ArrayReverse(arrayHigh);
//ArrayReverse(arrayLow);
//ArrayReverse(arrayClose);


   for(int i = 0; i < totalRates; i++) {

      price     = getPrice(inpPrice, arrayOpen, arrayClose, arrayHigh, arrayLow, i, totalRates);
      deviation = iEmaDeviation(price, periodos, i, totalRates);

      bufferMe[i] = iCustomMa(inpMaMethod, price, periodos, i, totalRates);

      //if (i >=  totalRates - limit) {

      bufferMe[i] = iCustomMa(inpMaMethod, price, periodos, i, totalRates);

      if (nbandas >= 24) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
         bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);
         bufferUp15[i] = bufferMe[i] + deviation * ((inpDeviations * 15) + offset * inpDeviations);
         bufferUp16[i] = bufferMe[i] + deviation * ((inpDeviations * 16) + offset * inpDeviations);
         bufferUp17[i] = bufferMe[i] + deviation * ((inpDeviations * 17) + offset * inpDeviations);
         bufferUp18[i] = bufferMe[i] + deviation * ((inpDeviations * 18) + offset * inpDeviations);
         bufferUp19[i] = bufferMe[i] + deviation * ((inpDeviations * 19) + offset * inpDeviations);
         bufferUp20[i] = bufferMe[i] + deviation * ((inpDeviations * 20) + offset * inpDeviations);
         bufferUp21[i] = bufferMe[i] + deviation * ((inpDeviations * 21) + offset * inpDeviations);
         bufferUp22[i] = bufferMe[i] + deviation * ((inpDeviations * 22) + offset * inpDeviations);
         bufferUp23[i] = bufferMe[i] + deviation * ((inpDeviations * 23) + offset * inpDeviations);
         bufferUp24[i] = bufferMe[i] + deviation * ((inpDeviations * 24) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
         bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
         bufferDn15[i] = bufferMe[i] - deviation * ((inpDeviations * 15) + offset * inpDeviations);
         bufferDn16[i] = bufferMe[i] - deviation * ((inpDeviations * 16) + offset * inpDeviations);
         bufferDn17[i] = bufferMe[i] - deviation * ((inpDeviations * 17) + offset * inpDeviations);
         bufferDn18[i] = bufferMe[i] - deviation * ((inpDeviations * 18) + offset * inpDeviations);
         bufferDn19[i] = bufferMe[i] - deviation * ((inpDeviations * 19) + offset * inpDeviations);
         bufferDn20[i] = bufferMe[i] - deviation * ((inpDeviations * 20) + offset * inpDeviations);
         bufferDn21[i] = bufferMe[i] - deviation * ((inpDeviations * 21) + offset * inpDeviations);
         bufferDn22[i] = bufferMe[i] - deviation * ((inpDeviations * 22) + offset * inpDeviations);
         bufferDn23[i] = bufferMe[i] - deviation * ((inpDeviations * 23) + offset * inpDeviations);
         bufferDn24[i] = bufferMe[i] - deviation * ((inpDeviations * 24) + offset * inpDeviations);
      } else if (nbandas == 23) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
         bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);
         bufferUp15[i] = bufferMe[i] + deviation * ((inpDeviations * 15) + offset * inpDeviations);
         bufferUp16[i] = bufferMe[i] + deviation * ((inpDeviations * 16) + offset * inpDeviations);
         bufferUp17[i] = bufferMe[i] + deviation * ((inpDeviations * 17) + offset * inpDeviations);
         bufferUp18[i] = bufferMe[i] + deviation * ((inpDeviations * 18) + offset * inpDeviations);
         bufferUp19[i] = bufferMe[i] + deviation * ((inpDeviations * 19) + offset * inpDeviations);
         bufferUp20[i] = bufferMe[i] + deviation * ((inpDeviations * 20) + offset * inpDeviations);
         bufferUp21[i] = bufferMe[i] + deviation * ((inpDeviations * 21) + offset * inpDeviations);
         bufferUp22[i] = bufferMe[i] + deviation * ((inpDeviations * 22) + offset * inpDeviations);
         bufferUp23[i] = bufferMe[i] + deviation * ((inpDeviations * 23) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
         bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
         bufferDn15[i] = bufferMe[i] - deviation * ((inpDeviations * 15) + offset * inpDeviations);
         bufferDn16[i] = bufferMe[i] - deviation * ((inpDeviations * 16) + offset * inpDeviations);
         bufferDn17[i] = bufferMe[i] - deviation * ((inpDeviations * 17) + offset * inpDeviations);
         bufferDn18[i] = bufferMe[i] - deviation * ((inpDeviations * 18) + offset * inpDeviations);
         bufferDn19[i] = bufferMe[i] - deviation * ((inpDeviations * 19) + offset * inpDeviations);
         bufferDn20[i] = bufferMe[i] - deviation * ((inpDeviations * 20) + offset * inpDeviations);
         bufferDn21[i] = bufferMe[i] - deviation * ((inpDeviations * 21) + offset * inpDeviations);
         bufferDn22[i] = bufferMe[i] - deviation * ((inpDeviations * 22) + offset * inpDeviations);
         bufferDn23[i] = bufferMe[i] - deviation * ((inpDeviations * 23) + offset * inpDeviations);
      } else if (nbandas == 22) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
         bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);
         bufferUp15[i] = bufferMe[i] + deviation * ((inpDeviations * 15) + offset * inpDeviations);
         bufferUp16[i] = bufferMe[i] + deviation * ((inpDeviations * 16) + offset * inpDeviations);
         bufferUp17[i] = bufferMe[i] + deviation * ((inpDeviations * 17) + offset * inpDeviations);
         bufferUp18[i] = bufferMe[i] + deviation * ((inpDeviations * 18) + offset * inpDeviations);
         bufferUp19[i] = bufferMe[i] + deviation * ((inpDeviations * 19) + offset * inpDeviations);
         bufferUp20[i] = bufferMe[i] + deviation * ((inpDeviations * 20) + offset * inpDeviations);
         bufferUp21[i] = bufferMe[i] + deviation * ((inpDeviations * 21) + offset * inpDeviations);
         bufferUp22[i] = bufferMe[i] + deviation * ((inpDeviations * 22) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
         bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
         bufferDn15[i] = bufferMe[i] - deviation * ((inpDeviations * 15) + offset * inpDeviations);
         bufferDn16[i] = bufferMe[i] - deviation * ((inpDeviations * 16) + offset * inpDeviations);
         bufferDn17[i] = bufferMe[i] - deviation * ((inpDeviations * 17) + offset * inpDeviations);
         bufferDn18[i] = bufferMe[i] - deviation * ((inpDeviations * 18) + offset * inpDeviations);
         bufferDn19[i] = bufferMe[i] - deviation * ((inpDeviations * 19) + offset * inpDeviations);
         bufferDn20[i] = bufferMe[i] - deviation * ((inpDeviations * 20) + offset * inpDeviations);
         bufferDn21[i] = bufferMe[i] - deviation * ((inpDeviations * 21) + offset * inpDeviations);
         bufferDn22[i] = bufferMe[i] - deviation * ((inpDeviations * 22) + offset * inpDeviations);
      } else if (nbandas == 21) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
         bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);
         bufferUp15[i] = bufferMe[i] + deviation * ((inpDeviations * 15) + offset * inpDeviations);
         bufferUp16[i] = bufferMe[i] + deviation * ((inpDeviations * 16) + offset * inpDeviations);
         bufferUp17[i] = bufferMe[i] + deviation * ((inpDeviations * 17) + offset * inpDeviations);
         bufferUp18[i] = bufferMe[i] + deviation * ((inpDeviations * 18) + offset * inpDeviations);
         bufferUp19[i] = bufferMe[i] + deviation * ((inpDeviations * 19) + offset * inpDeviations);
         bufferUp20[i] = bufferMe[i] + deviation * ((inpDeviations * 20) + offset * inpDeviations);
         bufferUp21[i] = bufferMe[i] + deviation * ((inpDeviations * 21) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
         bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
         bufferDn15[i] = bufferMe[i] - deviation * ((inpDeviations * 15) + offset * inpDeviations);
         bufferDn16[i] = bufferMe[i] - deviation * ((inpDeviations * 16) + offset * inpDeviations);
         bufferDn17[i] = bufferMe[i] - deviation * ((inpDeviations * 17) + offset * inpDeviations);
         bufferDn18[i] = bufferMe[i] - deviation * ((inpDeviations * 18) + offset * inpDeviations);
         bufferDn19[i] = bufferMe[i] - deviation * ((inpDeviations * 19) + offset * inpDeviations);
         bufferDn20[i] = bufferMe[i] - deviation * ((inpDeviations * 20) + offset * inpDeviations);
         bufferDn21[i] = bufferMe[i] - deviation * ((inpDeviations * 21) + offset * inpDeviations);
      } else if (nbandas == 20) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
         bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);
         bufferUp15[i] = bufferMe[i] + deviation * ((inpDeviations * 15) + offset * inpDeviations);
         bufferUp16[i] = bufferMe[i] + deviation * ((inpDeviations * 16) + offset * inpDeviations);
         bufferUp17[i] = bufferMe[i] + deviation * ((inpDeviations * 17) + offset * inpDeviations);
         bufferUp18[i] = bufferMe[i] + deviation * ((inpDeviations * 18) + offset * inpDeviations);
         bufferUp19[i] = bufferMe[i] + deviation * ((inpDeviations * 19) + offset * inpDeviations);
         bufferUp20[i] = bufferMe[i] + deviation * ((inpDeviations * 20) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
         bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
         bufferDn15[i] = bufferMe[i] - deviation * ((inpDeviations * 15) + offset * inpDeviations);
         bufferDn16[i] = bufferMe[i] - deviation * ((inpDeviations * 16) + offset * inpDeviations);
         bufferDn17[i] = bufferMe[i] - deviation * ((inpDeviations * 17) + offset * inpDeviations);
         bufferDn18[i] = bufferMe[i] - deviation * ((inpDeviations * 18) + offset * inpDeviations);
         bufferDn19[i] = bufferMe[i] - deviation * ((inpDeviations * 19) + offset * inpDeviations);
         bufferDn20[i] = bufferMe[i] - deviation * ((inpDeviations * 20) + offset * inpDeviations);
      } else if (nbandas == 19) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
         bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);
         bufferUp15[i] = bufferMe[i] + deviation * ((inpDeviations * 15) + offset * inpDeviations);
         bufferUp16[i] = bufferMe[i] + deviation * ((inpDeviations * 16) + offset * inpDeviations);
         bufferUp17[i] = bufferMe[i] + deviation * ((inpDeviations * 17) + offset * inpDeviations);
         bufferUp18[i] = bufferMe[i] + deviation * ((inpDeviations * 18) + offset * inpDeviations);
         bufferUp19[i] = bufferMe[i] + deviation * ((inpDeviations * 19) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
         bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
         bufferDn15[i] = bufferMe[i] - deviation * ((inpDeviations * 15) + offset * inpDeviations);
         bufferDn16[i] = bufferMe[i] - deviation * ((inpDeviations * 16) + offset * inpDeviations);
         bufferDn17[i] = bufferMe[i] - deviation * ((inpDeviations * 17) + offset * inpDeviations);
         bufferDn18[i] = bufferMe[i] - deviation * ((inpDeviations * 18) + offset * inpDeviations);
         bufferDn19[i] = bufferMe[i] - deviation * ((inpDeviations * 19) + offset * inpDeviations);
      } else if (nbandas == 18) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
         bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);
         bufferUp15[i] = bufferMe[i] + deviation * ((inpDeviations * 15) + offset * inpDeviations);
         bufferUp16[i] = bufferMe[i] + deviation * ((inpDeviations * 16) + offset * inpDeviations);
         bufferUp17[i] = bufferMe[i] + deviation * ((inpDeviations * 17) + offset * inpDeviations);
         bufferUp18[i] = bufferMe[i] + deviation * ((inpDeviations * 18) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
         bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
         bufferDn15[i] = bufferMe[i] - deviation * ((inpDeviations * 15) + offset * inpDeviations);
         bufferDn16[i] = bufferMe[i] - deviation * ((inpDeviations * 16) + offset * inpDeviations);
         bufferDn17[i] = bufferMe[i] - deviation * ((inpDeviations * 17) + offset * inpDeviations);
         bufferDn18[i] = bufferMe[i] - deviation * ((inpDeviations * 18) + offset * inpDeviations);
      } else if (nbandas == 17) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
         bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);
         bufferUp15[i] = bufferMe[i] + deviation * ((inpDeviations * 15) + offset * inpDeviations);
         bufferUp16[i] = bufferMe[i] + deviation * ((inpDeviations * 16) + offset * inpDeviations);
         bufferUp17[i] = bufferMe[i] + deviation * ((inpDeviations * 17) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
         bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
         bufferDn15[i] = bufferMe[i] - deviation * ((inpDeviations * 15) + offset * inpDeviations);
         bufferDn16[i] = bufferMe[i] - deviation * ((inpDeviations * 16) + offset * inpDeviations);
         bufferDn17[i] = bufferMe[i] - deviation * ((inpDeviations * 17) + offset * inpDeviations);
      } else if (nbandas == 16) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
         bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);
         bufferUp15[i] = bufferMe[i] + deviation * ((inpDeviations * 15) + offset * inpDeviations);
         bufferUp16[i] = bufferMe[i] + deviation * ((inpDeviations * 16) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
         bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
         bufferDn15[i] = bufferMe[i] - deviation * ((inpDeviations * 15) + offset * inpDeviations);
         bufferDn16[i] = bufferMe[i] - deviation * ((inpDeviations * 16) + offset * inpDeviations);
      } else if (nbandas == 15) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
         bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);
         bufferUp15[i] = bufferMe[i] + deviation * ((inpDeviations * 15) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
         bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
         bufferDn15[i] = bufferMe[i] - deviation * ((inpDeviations * 15) + offset * inpDeviations);
      } else if (nbandas == 14) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
         bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
         bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
      } else if (nbandas == 13) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
         bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
      } else if (nbandas == 12) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
         bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
      } else if (nbandas == 11) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
         bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
      } else if (nbandas == 10) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
         bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
      } else if (nbandas == 9) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
         bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
      } else if (nbandas == 8) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
         bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
      } else if (nbandas == 7) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
         bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
      } else if (nbandas == 6) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
         bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
      } else if (nbandas == 5) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
         bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
      } else if (nbandas == 4) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
         bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
      } else if (nbandas == 3) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
      } else if (nbandas == 2) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);


         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);

      } else if (nbandas == 1) {
         bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);

         bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);

      }
      //} else {
      //   bufferMe[i] = 0;
      //}

   }
//ArrayReverse(bufferMe);
   return(true);
}

//+------------------------------------------------------------------+
//| Custom indicator calculation function                            |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {

   if (!useTimer) {

      //if(Bars(_Symbol, _Period) < rates_total)
      //   return(-1);

      //if (totalRates >= limitCandles)
      //   totalRates = limitCandles;

      if(periodos >= rates_total)
         periodos = rates_total;

      ArrayInitialize(bufferUp1, 0);
      ArrayInitialize(bufferUp2, 0);
      ArrayInitialize(bufferUp3, 0);
      ArrayInitialize(bufferUp4, 0);
      ArrayInitialize(bufferUp5, 0);
      ArrayInitialize(bufferUp6, 0);
      ArrayInitialize(bufferUp7, 0);
      ArrayInitialize(bufferUp8, 0);
      ArrayInitialize(bufferUp9, 0);
      ArrayInitialize(bufferUp10, 0);
      ArrayInitialize(bufferUp11, 0);
      ArrayInitialize(bufferUp12, 0);
      ArrayInitialize(bufferUp13, 0);
      ArrayInitialize(bufferUp14, 0);
      ArrayInitialize(bufferUp15, 0);
      ArrayInitialize(bufferUp16, 0);
      ArrayInitialize(bufferUp17, 0);
      ArrayInitialize(bufferUp18, 0);
      ArrayInitialize(bufferUp19, 0);
      ArrayInitialize(bufferUp20, 0);
      ArrayInitialize(bufferUp21, 0);
      ArrayInitialize(bufferUp22, 0);
      ArrayInitialize(bufferUp23, 0);
      ArrayInitialize(bufferUp24, 0);

      ArrayInitialize(bufferDn1, 0);
      ArrayInitialize(bufferDn2, 0);
      ArrayInitialize(bufferDn3, 0);
      ArrayInitialize(bufferDn4, 0);
      ArrayInitialize(bufferDn5, 0);
      ArrayInitialize(bufferDn6, 0);
      ArrayInitialize(bufferDn7, 0);
      ArrayInitialize(bufferDn8, 0);
      ArrayInitialize(bufferDn9, 0);
      ArrayInitialize(bufferDn10, 0);
      ArrayInitialize(bufferDn11, 0);
      ArrayInitialize(bufferDn12, 0);
      ArrayInitialize(bufferDn13, 0);
      ArrayInitialize(bufferDn14, 0);
      ArrayInitialize(bufferDn15, 0);
      ArrayInitialize(bufferDn16, 0);
      ArrayInitialize(bufferDn17, 0);
      ArrayInitialize(bufferDn18, 0);
      ArrayInitialize(bufferDn19, 0);
      ArrayInitialize(bufferDn20, 0);
      ArrayInitialize(bufferDn21, 0);
      ArrayInitialize(bufferDn22, 0);
      ArrayInitialize(bufferDn23, 0);
      ArrayInitialize(bufferDn24, 0);

      if (nbandas < 24) ArrayFree(bufferUp24);
      if (nbandas < 24) ArrayFree(bufferDn24);
      if (nbandas < 23) ArrayFree(bufferUp23);
      if (nbandas < 23) ArrayFree(bufferDn23);
      if (nbandas < 22) ArrayFree(bufferUp22);
      if (nbandas < 22) ArrayFree(bufferDn22);
      if (nbandas < 21) ArrayFree(bufferUp21);
      if (nbandas < 21) ArrayFree(bufferDn21);
      if (nbandas < 20) ArrayFree(bufferUp20);
      if (nbandas < 20) ArrayFree(bufferDn20);
      if (nbandas < 19) ArrayFree(bufferUp19);
      if (nbandas < 19) ArrayFree(bufferDn19);
      if (nbandas < 18) ArrayFree(bufferUp18);
      if (nbandas < 18) ArrayFree(bufferDn18);
      if (nbandas < 17) ArrayFree(bufferUp17);
      if (nbandas < 17) ArrayFree(bufferDn17);
      if (nbandas < 16) ArrayFree(bufferUp16);
      if (nbandas < 16) ArrayFree(bufferDn16);
      if (nbandas < 15) ArrayFree(bufferUp15);
      if (nbandas < 15) ArrayFree(bufferDn15);
      if (nbandas < 14) ArrayFree(bufferUp14);
      if (nbandas < 14) ArrayFree(bufferDn14);
      if (nbandas < 13) ArrayFree(bufferUp13);
      if (nbandas < 13) ArrayFree(bufferDn13);
      if (nbandas < 12) ArrayFree(bufferUp12);
      if (nbandas < 12) ArrayFree(bufferDn12);
      if (nbandas < 11) ArrayFree(bufferUp11);
      if (nbandas < 11) ArrayFree(bufferDn11);
      if (nbandas < 10) ArrayFree(bufferUp10);
      if (nbandas < 10) ArrayFree(bufferDn10);
      if (nbandas < 9) ArrayFree(bufferUp9);
      if (nbandas < 9) ArrayFree(bufferDn9);
      if (nbandas < 8) ArrayFree(bufferUp8);
      if (nbandas < 8) ArrayFree(bufferDn8);
      if (nbandas < 7) ArrayFree(bufferUp7);
      if (nbandas < 7) ArrayFree(bufferDn7);
      if (nbandas < 6) ArrayFree(bufferUp6);
      if (nbandas < 6) ArrayFree(bufferDn6);
      if (nbandas < 5) ArrayFree(bufferUp5);
      if (nbandas < 5) ArrayFree(bufferDn5);
      if (nbandas < 4) ArrayFree(bufferUp4);
      if (nbandas < 4) ArrayFree(bufferDn4);
      if (nbandas < 3) ArrayFree(bufferUp3);
      if (nbandas < 3) ArrayFree(bufferDn3);
      if (nbandas < 2) ArrayFree(bufferUp2);
      if (nbandas < 2) ArrayFree(bufferDn2);
      if (nbandas < 1) ArrayFree(bufferUp1);
      if (nbandas < 1) ArrayFree(bufferDn1);

      for(int i = (int)MathMax(prev_calculated - 1, 0); i < rates_total && !IsStopped(); i++) {
         double price     = getPrice(inpPrice, open, close, high, low, i, rates_total);
         double deviation = iEmaDeviation(price, periodos, i, rates_total);

         bufferMe[i] = iCustomMa(inpMaMethod, price, periodos, i, rates_total);

         if (nbandas >= 24) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
            bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);
            bufferUp15[i] = bufferMe[i] + deviation * ((inpDeviations * 15) + offset * inpDeviations);
            bufferUp16[i] = bufferMe[i] + deviation * ((inpDeviations * 16) + offset * inpDeviations);
            bufferUp17[i] = bufferMe[i] + deviation * ((inpDeviations * 17) + offset * inpDeviations);
            bufferUp18[i] = bufferMe[i] + deviation * ((inpDeviations * 18) + offset * inpDeviations);
            bufferUp19[i] = bufferMe[i] + deviation * ((inpDeviations * 19) + offset * inpDeviations);
            bufferUp20[i] = bufferMe[i] + deviation * ((inpDeviations * 20) + offset * inpDeviations);
            bufferUp21[i] = bufferMe[i] + deviation * ((inpDeviations * 21) + offset * inpDeviations);
            bufferUp22[i] = bufferMe[i] + deviation * ((inpDeviations * 22) + offset * inpDeviations);
            bufferUp23[i] = bufferMe[i] + deviation * ((inpDeviations * 23) + offset * inpDeviations);
            bufferUp24[i] = bufferMe[i] + deviation * ((inpDeviations * 24) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
            bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
            bufferDn15[i] = bufferMe[i] - deviation * ((inpDeviations * 15) + offset * inpDeviations);
            bufferDn16[i] = bufferMe[i] - deviation * ((inpDeviations * 16) + offset * inpDeviations);
            bufferDn17[i] = bufferMe[i] - deviation * ((inpDeviations * 17) + offset * inpDeviations);
            bufferDn18[i] = bufferMe[i] - deviation * ((inpDeviations * 18) + offset * inpDeviations);
            bufferDn19[i] = bufferMe[i] - deviation * ((inpDeviations * 19) + offset * inpDeviations);
            bufferDn20[i] = bufferMe[i] - deviation * ((inpDeviations * 20) + offset * inpDeviations);
            bufferDn21[i] = bufferMe[i] - deviation * ((inpDeviations * 21) + offset * inpDeviations);
            bufferDn22[i] = bufferMe[i] - deviation * ((inpDeviations * 22) + offset * inpDeviations);
            bufferDn23[i] = bufferMe[i] - deviation * ((inpDeviations * 23) + offset * inpDeviations);
            bufferDn24[i] = bufferMe[i] - deviation * ((inpDeviations * 24) + offset * inpDeviations);
         } else if (nbandas == 23) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
            bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);
            bufferUp15[i] = bufferMe[i] + deviation * ((inpDeviations * 15) + offset * inpDeviations);
            bufferUp16[i] = bufferMe[i] + deviation * ((inpDeviations * 16) + offset * inpDeviations);
            bufferUp17[i] = bufferMe[i] + deviation * ((inpDeviations * 17) + offset * inpDeviations);
            bufferUp18[i] = bufferMe[i] + deviation * ((inpDeviations * 18) + offset * inpDeviations);
            bufferUp19[i] = bufferMe[i] + deviation * ((inpDeviations * 19) + offset * inpDeviations);
            bufferUp20[i] = bufferMe[i] + deviation * ((inpDeviations * 20) + offset * inpDeviations);
            bufferUp21[i] = bufferMe[i] + deviation * ((inpDeviations * 21) + offset * inpDeviations);
            bufferUp22[i] = bufferMe[i] + deviation * ((inpDeviations * 22) + offset * inpDeviations);
            bufferUp23[i] = bufferMe[i] + deviation * ((inpDeviations * 23) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
            bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
            bufferDn15[i] = bufferMe[i] - deviation * ((inpDeviations * 15) + offset * inpDeviations);
            bufferDn16[i] = bufferMe[i] - deviation * ((inpDeviations * 16) + offset * inpDeviations);
            bufferDn17[i] = bufferMe[i] - deviation * ((inpDeviations * 17) + offset * inpDeviations);
            bufferDn18[i] = bufferMe[i] - deviation * ((inpDeviations * 18) + offset * inpDeviations);
            bufferDn19[i] = bufferMe[i] - deviation * ((inpDeviations * 19) + offset * inpDeviations);
            bufferDn20[i] = bufferMe[i] - deviation * ((inpDeviations * 20) + offset * inpDeviations);
            bufferDn21[i] = bufferMe[i] - deviation * ((inpDeviations * 21) + offset * inpDeviations);
            bufferDn22[i] = bufferMe[i] - deviation * ((inpDeviations * 22) + offset * inpDeviations);
            bufferDn23[i] = bufferMe[i] - deviation * ((inpDeviations * 23) + offset * inpDeviations);
         } else if (nbandas == 22) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
            bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);
            bufferUp15[i] = bufferMe[i] + deviation * ((inpDeviations * 15) + offset * inpDeviations);
            bufferUp16[i] = bufferMe[i] + deviation * ((inpDeviations * 16) + offset * inpDeviations);
            bufferUp17[i] = bufferMe[i] + deviation * ((inpDeviations * 17) + offset * inpDeviations);
            bufferUp18[i] = bufferMe[i] + deviation * ((inpDeviations * 18) + offset * inpDeviations);
            bufferUp19[i] = bufferMe[i] + deviation * ((inpDeviations * 19) + offset * inpDeviations);
            bufferUp20[i] = bufferMe[i] + deviation * ((inpDeviations * 20) + offset * inpDeviations);
            bufferUp21[i] = bufferMe[i] + deviation * ((inpDeviations * 21) + offset * inpDeviations);
            bufferUp22[i] = bufferMe[i] + deviation * ((inpDeviations * 22) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
            bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
            bufferDn15[i] = bufferMe[i] - deviation * ((inpDeviations * 15) + offset * inpDeviations);
            bufferDn16[i] = bufferMe[i] - deviation * ((inpDeviations * 16) + offset * inpDeviations);
            bufferDn17[i] = bufferMe[i] - deviation * ((inpDeviations * 17) + offset * inpDeviations);
            bufferDn18[i] = bufferMe[i] - deviation * ((inpDeviations * 18) + offset * inpDeviations);
            bufferDn19[i] = bufferMe[i] - deviation * ((inpDeviations * 19) + offset * inpDeviations);
            bufferDn20[i] = bufferMe[i] - deviation * ((inpDeviations * 20) + offset * inpDeviations);
            bufferDn21[i] = bufferMe[i] - deviation * ((inpDeviations * 21) + offset * inpDeviations);
            bufferDn22[i] = bufferMe[i] - deviation * ((inpDeviations * 22) + offset * inpDeviations);
         } else if (nbandas == 21) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
            bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);
            bufferUp15[i] = bufferMe[i] + deviation * ((inpDeviations * 15) + offset * inpDeviations);
            bufferUp16[i] = bufferMe[i] + deviation * ((inpDeviations * 16) + offset * inpDeviations);
            bufferUp17[i] = bufferMe[i] + deviation * ((inpDeviations * 17) + offset * inpDeviations);
            bufferUp18[i] = bufferMe[i] + deviation * ((inpDeviations * 18) + offset * inpDeviations);
            bufferUp19[i] = bufferMe[i] + deviation * ((inpDeviations * 19) + offset * inpDeviations);
            bufferUp20[i] = bufferMe[i] + deviation * ((inpDeviations * 20) + offset * inpDeviations);
            bufferUp21[i] = bufferMe[i] + deviation * ((inpDeviations * 21) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
            bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
            bufferDn15[i] = bufferMe[i] - deviation * ((inpDeviations * 15) + offset * inpDeviations);
            bufferDn16[i] = bufferMe[i] - deviation * ((inpDeviations * 16) + offset * inpDeviations);
            bufferDn17[i] = bufferMe[i] - deviation * ((inpDeviations * 17) + offset * inpDeviations);
            bufferDn18[i] = bufferMe[i] - deviation * ((inpDeviations * 18) + offset * inpDeviations);
            bufferDn19[i] = bufferMe[i] - deviation * ((inpDeviations * 19) + offset * inpDeviations);
            bufferDn20[i] = bufferMe[i] - deviation * ((inpDeviations * 20) + offset * inpDeviations);
            bufferDn21[i] = bufferMe[i] - deviation * ((inpDeviations * 21) + offset * inpDeviations);
         } else if (nbandas == 20) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
            bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);
            bufferUp15[i] = bufferMe[i] + deviation * ((inpDeviations * 15) + offset * inpDeviations);
            bufferUp16[i] = bufferMe[i] + deviation * ((inpDeviations * 16) + offset * inpDeviations);
            bufferUp17[i] = bufferMe[i] + deviation * ((inpDeviations * 17) + offset * inpDeviations);
            bufferUp18[i] = bufferMe[i] + deviation * ((inpDeviations * 18) + offset * inpDeviations);
            bufferUp19[i] = bufferMe[i] + deviation * ((inpDeviations * 19) + offset * inpDeviations);
            bufferUp20[i] = bufferMe[i] + deviation * ((inpDeviations * 20) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
            bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
            bufferDn15[i] = bufferMe[i] - deviation * ((inpDeviations * 15) + offset * inpDeviations);
            bufferDn16[i] = bufferMe[i] - deviation * ((inpDeviations * 16) + offset * inpDeviations);
            bufferDn17[i] = bufferMe[i] - deviation * ((inpDeviations * 17) + offset * inpDeviations);
            bufferDn18[i] = bufferMe[i] - deviation * ((inpDeviations * 18) + offset * inpDeviations);
            bufferDn19[i] = bufferMe[i] - deviation * ((inpDeviations * 19) + offset * inpDeviations);
            bufferDn20[i] = bufferMe[i] - deviation * ((inpDeviations * 20) + offset * inpDeviations);
         } else if (nbandas == 19) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
            bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);
            bufferUp15[i] = bufferMe[i] + deviation * ((inpDeviations * 15) + offset * inpDeviations);
            bufferUp16[i] = bufferMe[i] + deviation * ((inpDeviations * 16) + offset * inpDeviations);
            bufferUp17[i] = bufferMe[i] + deviation * ((inpDeviations * 17) + offset * inpDeviations);
            bufferUp18[i] = bufferMe[i] + deviation * ((inpDeviations * 18) + offset * inpDeviations);
            bufferUp19[i] = bufferMe[i] + deviation * ((inpDeviations * 19) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
            bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
            bufferDn15[i] = bufferMe[i] - deviation * ((inpDeviations * 15) + offset * inpDeviations);
            bufferDn16[i] = bufferMe[i] - deviation * ((inpDeviations * 16) + offset * inpDeviations);
            bufferDn17[i] = bufferMe[i] - deviation * ((inpDeviations * 17) + offset * inpDeviations);
            bufferDn18[i] = bufferMe[i] - deviation * ((inpDeviations * 18) + offset * inpDeviations);
            bufferDn19[i] = bufferMe[i] - deviation * ((inpDeviations * 19) + offset * inpDeviations);
         } else if (nbandas == 18) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
            bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);
            bufferUp15[i] = bufferMe[i] + deviation * ((inpDeviations * 15) + offset * inpDeviations);
            bufferUp16[i] = bufferMe[i] + deviation * ((inpDeviations * 16) + offset * inpDeviations);
            bufferUp17[i] = bufferMe[i] + deviation * ((inpDeviations * 17) + offset * inpDeviations);
            bufferUp18[i] = bufferMe[i] + deviation * ((inpDeviations * 18) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
            bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
            bufferDn15[i] = bufferMe[i] - deviation * ((inpDeviations * 15) + offset * inpDeviations);
            bufferDn16[i] = bufferMe[i] - deviation * ((inpDeviations * 16) + offset * inpDeviations);
            bufferDn17[i] = bufferMe[i] - deviation * ((inpDeviations * 17) + offset * inpDeviations);
            bufferDn18[i] = bufferMe[i] - deviation * ((inpDeviations * 18) + offset * inpDeviations);
         } else if (nbandas == 17) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
            bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);
            bufferUp15[i] = bufferMe[i] + deviation * ((inpDeviations * 15) + offset * inpDeviations);
            bufferUp16[i] = bufferMe[i] + deviation * ((inpDeviations * 16) + offset * inpDeviations);
            bufferUp17[i] = bufferMe[i] + deviation * ((inpDeviations * 17) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
            bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
            bufferDn15[i] = bufferMe[i] - deviation * ((inpDeviations * 15) + offset * inpDeviations);
            bufferDn16[i] = bufferMe[i] - deviation * ((inpDeviations * 16) + offset * inpDeviations);
            bufferDn17[i] = bufferMe[i] - deviation * ((inpDeviations * 17) + offset * inpDeviations);
         } else if (nbandas == 16) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
            bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);
            bufferUp15[i] = bufferMe[i] + deviation * ((inpDeviations * 15) + offset * inpDeviations);
            bufferUp16[i] = bufferMe[i] + deviation * ((inpDeviations * 16) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
            bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
            bufferDn15[i] = bufferMe[i] - deviation * ((inpDeviations * 15) + offset * inpDeviations);
            bufferDn16[i] = bufferMe[i] - deviation * ((inpDeviations * 16) + offset * inpDeviations);
         } else if (nbandas == 15) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
            bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);
            bufferUp15[i] = bufferMe[i] + deviation * ((inpDeviations * 15) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
            bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
            bufferDn15[i] = bufferMe[i] - deviation * ((inpDeviations * 15) + offset * inpDeviations);
         } else if (nbandas == 14) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
            bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
            bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
         } else if (nbandas == 13) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
            bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
         } else if (nbandas == 12) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
            bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
         } else if (nbandas == 11) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
            bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
         } else if (nbandas == 10) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
            bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
         } else if (nbandas == 9) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
            bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
         } else if (nbandas == 8) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
            bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
         } else if (nbandas == 7) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
            bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
         } else if (nbandas == 6) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
            bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
         } else if (nbandas == 5) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
            bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
         } else if (nbandas == 4) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
            bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
         } else if (nbandas == 3) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
         } else if (nbandas == 2) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);
            bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
            bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
         } else if (nbandas == 1) {
            bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations) + offset * inpDeviations);

            bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations) + offset * inpDeviations);
         }
      }

      if (debug)
         Print("BBands EMA " + " " + _Symbol + ":" + GetTimeFrame(Period()) + " ok");
   }

   return(rates_total);
}

////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
void OnTimer() {
   if (useTimer)
      CheckTimer();
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _edevInstances 1
#define _edevInstancesSize 2
double workEmaDeviation[][_edevInstances * _edevInstancesSize];
#define _ema0 0
#define _ema1 1

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iEmaDeviation(double price, double period, int i, int bars, int instanceNo = 0) {
   double alpha, result;

   if(ArrayRange(workEmaDeviation, 0) != bars)
      ArrayResize(workEmaDeviation, bars);

   instanceNo *= _edevInstancesSize;

   workEmaDeviation[i][instanceNo + _ema0] = price;
   workEmaDeviation[i][instanceNo + _ema1] = price;
   if(i > 0 && period > 1) {
      alpha = 2.0 / (1.0 + period);
      workEmaDeviation[i][instanceNo + _ema0] = workEmaDeviation[i - 1][instanceNo + _ema0] + alpha * (price - workEmaDeviation[i - 1][instanceNo + _ema0]);
      workEmaDeviation[i][instanceNo + _ema1] = workEmaDeviation[i - 1][instanceNo + _ema1] + alpha * (price * price - workEmaDeviation[i - 1][instanceNo + _ema1]);
   }
//result = MathSqrt(period * (workEmaDeviation[i][instanceNo + _ema1] - workEmaDeviation[i][instanceNo + _ema0] * workEmaDeviation[i][instanceNo + _ema0]) / MathMax(period - 1, 1));
// we need to use an aboslute number to avoid negative numbers and nan error
   result = MathSqrt(MathAbs(period * (workEmaDeviation[i][instanceNo + _ema1] - workEmaDeviation[i][instanceNo + _ema0] * workEmaDeviation[i][instanceNo + _ema0]) / MathMax(period - 1, 1)));
   return result;
}

#define _maInstances 2
#define _maWorkBufferx1 1*_maInstances
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iCustomMa(int mode, double price, double length, int r, int bars, int instanceNo = 0) {
   switch(mode) {
   case ma_sma   :
      return(iSma(price, (int)length, r, bars, instanceNo));
   case ma_ema   :
      return(iEma(price, length, r, bars, instanceNo));
   case ma_smma  :
      return(iSmma(price, (int)length, r, bars, instanceNo));
   case ma_lwma  :
      return(iLwma(price, (int)length, r, bars, instanceNo));
   default       :
      return(price);
   }
}

double workSma[][_maWorkBufferx1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iSma(double price, int period, int r, int _bars, int instanceNo = 0) {
   if(ArrayRange(workSma, 0) != _bars)
      ArrayResize(workSma, _bars);

   workSma[r][instanceNo] = price;
   double avg = price;
   int k = 1;
   for(; k < period && (r - k) >= 0; k++)
      avg += workSma[r - k][instanceNo];

   return(avg / (double)k);
}

double workEma[][_maWorkBufferx1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iEma(double price, double period, int r, int _bars, int instanceNo = 0) {
   if(ArrayRange(workEma, 0) != _bars)
      ArrayResize(workEma, _bars);

   workEma[r][instanceNo] = price;
   if(r > 0 && period > 1)
      workEma[r][instanceNo] = workEma[r - 1][instanceNo] + (2.0 / (1.0 + period)) * (price - workEma[r - 1][instanceNo]);
   return(workEma[r][instanceNo]);
}

double workSmma[][_maWorkBufferx1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iSmma(double price, double period, int r, int _bars, int instanceNo = 0) {
   if(ArrayRange(workSmma, 0) != _bars)
      ArrayResize(workSmma, _bars);

   workSmma[r][instanceNo] = price;
   if(r > 1 && period > 1)
      workSmma[r][instanceNo] = workSmma[r - 1][instanceNo] + (price - workSmma[r - 1][instanceNo]) / period;
   return(workSmma[r][instanceNo]);
}

double workLwma[][_maWorkBufferx1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iLwma(double price, double period, int r, int _bars, int instanceNo = 0) {
   if(ArrayRange(workLwma, 0) != _bars)
      ArrayResize(workLwma, _bars);

   workLwma[r][instanceNo] = price;
   if(period < 1)
      return(price);

   double sumw = period;
   double sum  = period * price;

   for(int k = 1; k < period && (r - k) >= 0; k++) {
      double weight = period - k;
      sumw  += weight;
      sum   += weight * workLwma[r - k][instanceNo];
   }
   return(sum / sumw);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getPrice(ENUM_APPLIED_PRICE tprice, const double &open[], const double &close[], const double &high[], const double &low[], int i, int _bars) {
   switch(tprice) {
   case PRICE_CLOSE:
      return(close[i]);
   case PRICE_OPEN:
      return(open[i]);
   case PRICE_HIGH:
      return(high[i]);
   case PRICE_LOW:
      return(low[i]);
   case PRICE_MEDIAN:
      return((high[i] + low[i]) / 2.0);
   case PRICE_TYPICAL:
      return((high[i] + low[i] + close[i]) / 3.0);
   case PRICE_WEIGHTED:
      return((high[i] + low[i] + close[i] + close[i]) / 4.0);
   }
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckTimer() {

   EventKillTimer();

   if(_updateTimer.Check() || !_lastOK) {
      _lastOK = Update();
      EventSetMillisecondTimer(WaitMilliseconds);

      ChartRedraw();
      if (debug)
         Print("BBands EMA " + " " + _Symbol + ":" + GetTimeFrame(Period()) + " ok");

      _updateTimer.Reset();
   } else {
      EventSetTimer(1);
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MillisecondTimer {

 private:
   int               _milliseconds;
 private:
   uint              _lastTick;

 public:
   void              MillisecondTimer(const int milliseconds, const bool reset = true) {
      _milliseconds = milliseconds;

      if(reset)
         Reset();
      else
         _lastTick = 0;
   }

 public:
   bool              Check() {
      uint now = getCurrentTick();
      bool stop = now >= _lastTick + _milliseconds;

      if(stop)
         _lastTick = now;

      return(stop);
   }

 public:
   void              Reset() {
      _lastTick = getCurrentTick();
   }

 private:
   uint              getCurrentTick() const {
      return(GetTickCount());
   }

};

MillisecondTimer *_updateTimer;

//+---------------------------------------------------------------------+
//| GetTimeFrame function - returns the textual timeframe               |
//+---------------------------------------------------------------------+
string GetTimeFrame(int lPeriod) {
   switch(lPeriod) {
   case PERIOD_M1:
      return("M1");
   case PERIOD_M2:
      return("M2");
   case PERIOD_M3:
      return("M3");
   case PERIOD_M4:
      return("M4");
   case PERIOD_M5:
      return("M5");
   case PERIOD_M6:
      return("M6");
   case PERIOD_M10:
      return("M10");
   case PERIOD_M12:
      return("M12");
   case PERIOD_M15:
      return("M15");
   case PERIOD_M20:
      return("M20");
   case PERIOD_M30:
      return("M30");
   case PERIOD_H1:
      return("H1");
   case PERIOD_H2:
      return("H2");
   case PERIOD_H3:
      return("H3");
   case PERIOD_H4:
      return("H4");
   case PERIOD_H6:
      return("H6");
   case PERIOD_H8:
      return("H8");
   case PERIOD_H12:
      return("H12");
   case PERIOD_D1:
      return("D1");
   case PERIOD_W1:
      return("W1");
   case PERIOD_MN1:
      return("MN1");
   }
   return IntegerToString(lPeriod);
}
//+------------------------------------------------------------------+
