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
input ENUM_BASE_CORNER InpCorner    = CORNER_LEFT_LOWER;  // Позиция таймера
input int              InpXOffset   = 1;                  // Смещение по оси X
input int              InpYOffset   = 1;                  // Смещение по оси Y

//--- Глобальные переменные
string label_name = "Countdown_Candle_Timer_Label";
int seconds_in_period = 0;


int OnInit() {
   if (!ObjectCreate(0, label_name, OBJ_LABEL, 0, 0, 0)) {
      Print("Не удалось создать текстовую метку. Ошибка: ", GetLastError());
      return INIT_FAILED;
   }
   
   seconds_in_period = PeriodSeconds();
   
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

   EventSetTimer(1);
   
   UpdateTimerText();

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {
   EventKillTimer();
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
   UpdateTimerText();
   return rates_total;
}

void OnTimer() {
   UpdateTimerText();
}

void UpdateTimerText() {
   static datetime last_current_time = 0;
   
   datetime current_time = TimeCurrent();
   if (current_time == last_current_time) {
      return;
   }
   
   last_current_time = current_time;

   datetime currentBarTime = iTime(NULL, 0, 0);
   
   long seconds_left = (long)(currentBarTime + seconds_in_period) - (long)current_time;
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
