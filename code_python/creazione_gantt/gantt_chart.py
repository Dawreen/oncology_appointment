from matplotlib.patches import Patch
import pandas as pd
import matplotlib.pyplot as plt
import datetime as dt

def datetime_convertion(giorno, ts):
    day0 = pd.to_datetime('2018-01-01 08:00')
    h = ts // 6
    m = (ts % 6) * 10
    ret = day0 + pd.Timedelta(days = giorno) + pd.Timedelta(hours = h) + pd.Timedelta(minutes = m)
    return ret

def gantt_chart(df_all, start_time, end_time):
    # creazione di un diagramma a barre orizontale con Pazienti sulla y 
    # che inizia dall'inizio ed ha lunghezza della durata
    tot_view = 15 # numero pazienti da vedere nel grafico
    df = df_all.tail(tot_view)
    #print(df)
    fig, ax = plt.subplots()
    ax.set_title('Diagramma nel tempo dei pazienti')


    min10 = pd.to_timedelta(10, unit="min") #tempo della visita a 10 minuti
    plt.barh(y=df.Paziente, left=df.inizio, width=min10, color='blue')
    plt.barh(y=df.Paziente, left=df.inizio+min10, width=pd.to_timedelta(df['attesa']*10, unit='minutes'), color='red')
    plt.barh(y=df.Paziente, left=df.inizio+pd.to_timedelta(df['attesa']*10, unit='minutes')+min10, width=df.durata-min10-pd.to_timedelta(df['attesa']*10), color='green')

    # legenda
    c_dict = {'visita':'blue', 'attesa':'red', 'infusione':'green'}
    legend_elemnts = [Patch(facecolor = c_dict[i], label = i) for i in c_dict]
    plt.legend(handles=legend_elemnts)

    # text
    i = 0
    for idx, row in df.iterrows():
        ax.text(x=row.inizio-min10, y=i, s=row.patologia, va='center', fontsize=9)
        if row.attesa > 0:
            ax.text(x=row.inizio+min10, y=i, s=str(row.attesa), va='center')
        if row.poltrona:
            ax.text(x=row.inizio+pd.to_timedelta(row.attesa*10, unit='minutes')+min10, y=i, s='poltrona', va='center')
        else:
            ax.text(x=row.inizio+pd.to_timedelta(row.attesa*10, unit='minutes')+min10, y=i, s='letto', va='center')
        i = i + 1
    
    p_start = df.inizio.min()
    p_end = df.fine.max()
    p_duration = (p_end - p_start)

    idx = pd.date_range(start_time, end_time, freq='h')

    x_ticks = idx
    x_labels = x_ticks.strftime('%H:%M')

    plt.xticks(ticks=x_ticks, labels=x_labels)
    plt.grid(axis='x', alpha=0.5)
    plt.gca().invert_yaxis()

    plt.show()

def main():
    # 2017-03-22 15:16:45
    df1 = pd.read_json('result.json')
    df2 = pd.read_json('path_pazienti.json')
    df3 = pd.read_json('pi.json')
    df = pd.merge(df1, df2, on="Paziente")
    df = pd.merge(df, df3, on="Paziente")
    print(df)
    day0 = pd.to_datetime('2018-01-01 08:00')
    df = df[df['visitato'] == True]

    # creazione dei tempi di inizio e fine
    df['inizio'] = day0 + pd.to_timedelta(df['giorno'], unit='D') + pd.to_timedelta(df['ts_inizio']*10, unit='minutes')
    df['fine'] = day0 + pd.to_timedelta(df['giorno'], unit='D') + pd.to_timedelta(df['ts_fine']*10, unit='minutes')
    df['durata'] = df.fine - df.inizio

    # ordinamento in base al momento di inizio (data e ora)
    df = df.sort_values(by= 'inizio', ascending = True)

    print(df)

    df_day1 = df[df['giorno'] == 1]
    #print(df_day1)
    df_day2 = df[df['giorno'] == 2]
    #print(df_day2)
    df_day3 = df[df['giorno'] == 3]
    #print(df_day3)
    df_day4 = df[df['giorno'] == 4]
    #print(df_day4)
    df_day5 = df[df['giorno'] == 5]
    #print(df_day5)

    gantt_chart(df_day1, '2018-01-02 07:30', '2018-01-02 17:30')
    #gantt_chart(df_day2, '2018-01-03 07:30', '2018-01-03 17:30')
    #gantt_chart(df_day3, '2018-01-04 07:30', '2018-01-04 17:30')
    #gantt_chart(df_day4, '2018-01-05 07:30', '2018-01-05 17:30')
    #gantt_chart(df_day5, '2018-01-06 07:30', '2018-01-06 17:30')


if __name__ == "__main__":
    main()