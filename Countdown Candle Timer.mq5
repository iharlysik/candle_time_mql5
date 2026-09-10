//+------------------------------------------------------------------+
//|                                                  CandleTimer.mq5 |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property link      "https://mql5.com"
#property version   "1.00"

// Индикатор будет отображаться прямо на графике цены
#property indicator_chart_window
// Нам не нужны графические буферы, так как вывод идет через текстовую метку
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


int OnInit() {
   // Создаем текстовую метку на графике
   if (!ObjectCreate(0, label_name, OBJ_LABEL, 0, 0, 0)) {
      Print("Не удалось создать текстовую метку. Ошибка: ", GetLastError());
      return INIT_FAILED;
   }
   
   // Настраиваем свойства метки
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

   // Инициализируем таймер с шагом в 1 секунду
   EventSetTimer(1);
   
   // Сразу обновляем текст при запуске
   UpdateTimerText();

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {
   // Обязательно уничтожаем таймер и удаляем объект с графика
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
   // При каждом новом тике также обновляем текст
   UpdateTimerText();
   return rates_total;
}

void OnTimer() {
   // Каждую секунду вызываем обновление текста
   UpdateTimerText();
}

void UpdateTimerText() {
   // Статические переменные сохраняют значения между вызовами функции
   static datetime last_current_time = 0;

   // 1. Получаем текущее время сервера
   datetime current_time = TimeCurrent();
   
   // ОПТИМИЗАЦИЯ: Если секунда не изменилась с прошлого вызова, сразу выходим
   if (current_time == last_current_time) {
      return;
   }
   
   last_current_time = current_time;

   // 2. Получаем время открытия текущего бара
   datetime bar_time[];
   if (CopyTime(_Symbol, _Period, 0, 1, bar_time) < 1) {
      return;
   }
   
   // 3. Рассчитываем оставшиеся секунды
   long seconds_left = (long)(bar_time[0] + PeriodSeconds()) - (long)current_time;
   if (seconds_left < 0) {
      seconds_left = 0;
   }
   
   // 4. Форматируем секунды в строку
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
