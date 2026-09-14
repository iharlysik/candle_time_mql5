//+------------------------------------------------------------------+
//|                                                  CandleTimer.mq5 |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property link      "https://mql5.com"
#property version   "1.00"

#property indicator_chart_window

#property indicator_buffers 0
#property indicator_plots   0


//--- Входные параметры
input color            InpTextColor = clrDarkViolet;      // Цвет текста
input int              InpFontSize  = 20;                 // Размер шрифта
input string           InpFontName  = "Verdana";          // Шрифт
input ENUM_BASE_CORNER InpCorner    = CORNER_RIGHT_LOWER;  // Позиция таймера
input int              InpXOffset   = 1;                  // Смещение по оси X
input int              InpYOffset   = 1;                  // Смещение по оси Y


//--- Глобальные переменные
string label_name = "Countdown_Candle_Timer_Label";
int seconds_in_period = 0;

struct ChartColors {
   color default_bid;
   color bull;
   color bear;
   color line;
};

ChartColors chart_colors;


int OnInit() {
   if (!ObjectCreate(0, label_name, OBJ_LABEL, 0, 0, 0)) {
      Print("Не удалось создать текстовую метку. Ошибка: ", GetLastError());
      return INIT_FAILED;
   }
   
   chart_colors.default_bid = (color)ChartGetInteger(0, CHART_COLOR_BID);
   seconds_in_period = PeriodSeconds();
   
   UpdateChartColors();
   
   SetLabelAnchor();
   ObjectSetInteger(0, label_name, OBJPROP_CORNER, InpCorner);
   ObjectSetInteger(0, label_name, OBJPROP_XDISTANCE, InpXOffset);
   ObjectSetInteger(0, label_name, OBJPROP_YDISTANCE, InpYOffset);
   ObjectSetInteger(0, label_name, OBJPROP_FONTSIZE, InpFontSize);
   ObjectSetString(0, label_name, OBJPROP_FONT, InpFontName);
   ObjectSetInteger(0, label_name, OBJPROP_COLOR, InpTextColor);
   ObjectSetInteger(0, label_name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, label_name, OBJPROP_HIDDEN, true);
   ObjectSetString(0, label_name, OBJPROP_TEXT, "00:00:00");
   
   datetime current_bar_time = iTime(NULL, 0, 0);
   UpdateTimerText(current_bar_time);

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {
   ChartSetInteger(0, CHART_COLOR_BID, chart_colors.default_bid);
   ObjectDelete(0, label_name);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int first_bar_index = rates_total - 1;
   
   ChangeBidLineColor(open[first_bar_index], close[first_bar_index]);
   UpdateTimerText(time[first_bar_index]);
   
   return rates_total;
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (id == CHARTEVENT_CHART_CHANGE) {
      UpdateChartColors();
      
      MqlRates rates[1];
      CopyRates(NULL, 0, 0, 1, rates);
   
      MqlRates rate = rates[0];
      ChangeBidLineColor(rate.open, rate.close);
      UpdateTimerText(rate.time);
   }
}

void UpdateTimerText(datetime current_bar_time) {
   static datetime last_current_time = 0;
   
   datetime current_time = TimeCurrent();
   if (current_time == last_current_time) {
      return;
   }
   
   last_current_time = current_time;
   
   long seconds_left = (long)(current_bar_time + seconds_in_period) - (long)current_time;
   if (seconds_left < 0) {
      seconds_left = 0;
   }
   
   long hours = seconds_left / 3600;
   long minutes = (seconds_left % 3600) / 60;
   long seconds = seconds_left % 60;
   
   string time_str = StringFormat("%02d:%02d:%02d", hours, minutes, seconds);
   ObjectSetString(0, label_name, OBJPROP_TEXT, time_str);
}

void SetLabelAnchor() {
   ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_LOWER;

   switch (InpCorner) {
      case CORNER_RIGHT_UPPER:
         anchor = ANCHOR_RIGHT_UPPER;
         break;
      case CORNER_RIGHT_LOWER:
         anchor = ANCHOR_RIGHT_LOWER;
         break;
      case CORNER_LEFT_UPPER:
         anchor = ANCHOR_LEFT_UPPER;
         break;
      case CORNER_LEFT_LOWER:
         anchor = ANCHOR_LEFT_LOWER;
         break;
   }
   
   ObjectSetInteger(0, label_name, OBJPROP_ANCHOR, anchor);
}

void ChangeBidLineColor(double open, double close) {
   static color last_color = clrNONE;
   color current_color = chart_colors.line;

   if (close > open)      current_color = chart_colors.bull;
   else if (open > close) current_color = chart_colors.bear;
   
   if (last_color != current_color) {
      last_color = current_color;
      ChartSetInteger(0, CHART_COLOR_BID, current_color);
   }
}

void UpdateChartColors() {
   chart_colors.bull = (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BULL);
   chart_colors.bear = (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BEAR);
   chart_colors.line = (color)ChartGetInteger(0, CHART_COLOR_CHART_LINE);
}
