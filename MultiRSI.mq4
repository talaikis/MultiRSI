#property version "1.0"
#property copyright "Copyright ? 2014-2016, Quantrade Corp."
#property link      "http: //quantrade.co.uk"

#property indicator_separate_window

#property indicator_buffers 5
#property indicator_color1 clrNONE
#property indicator_color2 clrNONE
#property indicator_color3 clrNONE
#property indicator_color4 clrNONE
#property indicator_color5 clrNONE
#property indicator_color6 clrGray
#property indicator_color7 clrRed
#property indicator_color8 clrGreen
#property indicator_color9 clrYellow

#property indicator_level1     20
#property indicator_level2     80
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT

extern int  per        = 3;
extern bool WildersRSI = false;
extern bool CutlerRSI  = false;
extern bool HarrisRSI  = false;
extern bool RSIIndex   = true;

string      email   = "";
string      licence = "";

double Buf_0[];
double RSI[];
double NDX[];
double WILDERG[];
double WILDERL[];
double CUTLER[];
double CUPb[];
double CDNb[];
double HARRIS[];

datetime lastAlertTime = 0;

string   cookie = NULL, headers;
char post[], result[];
int      res;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
{
//---- indicators
    //SetIndexStyle(5, DRAW_LINE, STYLE_SOLID, 2);

    SetIndexBuffer(0, Buf_0);
    SetIndexBuffer(1, WILDERG);
    SetIndexBuffer(2, WILDERL);
    SetIndexBuffer(3, CUPb);
    SetIndexBuffer(4, CDNb);
    SetIndexBuffer(5, RSI);
    SetIndexBuffer(6, CUTLER);
    SetIndexBuffer(7, HARRIS);
    SetIndexBuffer(8, NDX);

    IndicatorSetDouble(INDICATOR_MINIMUM, -5);
    IndicatorSetDouble(INDICATOR_MAXIMUM, 105);

//----
    return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
//----

//----
    return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
    int bars = Bars - per;
    int i;

    if (Refresh())
    {
        for (i = bars; i >= 0; i--)
        {
            if (Close[i + 1] != 0)
            {
                Buf_0[i] = Close[i] - Close[i + 1];
            }
            else
            {
                Buf_0[i] = 0;
            }
        }

        for (i = bars; i >= 0; i--)
        {
            WILDERG[i] = WILDERGain(Buf_0, per, i);
            WILDERL[i] = WILDERLoss(Buf_0, per, i);
            CUPb[i]    = CUP(Buf_0, per, i);
            CDNb[i]    = CDN(Buf_0, per, i);
        }

        for (i = bars; i >= 0; i--)
        {
            double ema  = iMAOnArray(WILDERL, 0, per, 0, MODE_EMA, i);
            double sma  = iMAOnArray(WILDERL, 0, per, 0, MODE_SMA, i);
            double sma1 = iMAOnArray(CDNb, 0, per, 0, MODE_SMA, i);

            if (ema != 0 && sma != 0 && sma1 != 0)
            {
                double rs1 = (1 + iMAOnArray(WILDERG, 0, per, 0, MODE_EMA, i) / ema);
                double rs2 = (1 + iMAOnArray(WILDERG, 0, per, 0, MODE_SMA, i) / sma);
                double rs3 = (1 + iMAOnArray(CUPb, 0, per, 0, MODE_SMA, i) / sma1);

                if (rs1 != 0 && rs2 != 0 && rs3 != 0)
                {
                    if (WildersRSI)
                        RSI[i] = (100 - 100 / rs1);
                    if (CutlerRSI)
                        CUTLER[i] = (100 - 100 / rs2);
                    if (HarrisRSI)
                        HARRIS[i] = (100 - 100 / rs3);
                    if (RSIIndex)
                        NDX[i] = ((100 - 100 / rs1) + (100 - 100 / rs2) + (100 - 100 / rs3)) / 3;
                }
                else
                {
                    RSI[i]    = 50;
                    CUTLER[i] = 50;
                    HARRIS[i] = 50;
                    NDX[i]    = 50;
                }
            }
            else
            {
                RSI[i]    = 50;
                CUTLER[i] = 50;
                HARRIS[i] = 50;
                NDX[i]    = 50;
            }
        }
    }
//----
    return(0);
}
//+------------------------------------------------------------------+

//update base only once a bar
bool Refresh()
{
    static datetime PrevBar;

    if (PrevBar != iTime(NULL, Period(), 0))
    {
        PrevBar = iTime(NULL, Period(), 0);
        return(true);
    }
    else
    {
        return(false);
    }
}


double WILDERGain(double X[], int per, int bar)
{
    double Gain = 0;

    for (int i = per - 1; i >= 0; i--)
    {
        if (X[bar + i] > 0)
        {
            Gain += X[i + bar];
        }
    }

    return(Gain);
}

double WILDERLoss(double X[], int per, int bar)
{
    double Loss = 0;

    for (int i = per - 1; i >= 0; i--)
    {
        if (X[bar + i] < 0)
        {
            Loss += X[i + bar];
        }
    }

    return(MathAbs(Loss));
}

double CUP(double X[], int per, int bar)
{
    double Up = 0;

    for (int i = per - 1; i >= 0; i--)
    {
        if (X[bar + i] > 0)
        {
            Up += 1;
        }
    }

    return(Up);
}

double CDN(double X[], int per, int bar)
{
    double Dn = 0;

    for (int i = per - 1; i >= 0; i--)
    {
        if (X[bar + i] < 0)
        {
            Dn += 1;
        }
    }

    return(Dn);
}
