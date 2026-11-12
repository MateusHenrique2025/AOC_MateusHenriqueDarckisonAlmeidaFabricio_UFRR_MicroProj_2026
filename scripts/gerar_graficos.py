import pandas as pd
import matplotlib.pyplot as plt
import re

# 1. Carregar os dados do CSV
colunas = ["Organizacao", "Arquivo", "Ciclos", "Instrucoes", "CPI", "IPC", "Ocupacao", "Erros"]
df = pd.read_csv("metricas.csv", header=None, names=colunas)

# Filtrar apenas as linhas que realmente têm o padrão "O1_Sx" ou "O2_Sx"
# Isso evita o erro de NaN se houver linhas em branco no CSV
df = df[df['Organizacao'].str.contains(r'_S\d+', na=False)]

# Extrair o Tamanho (número) e o Tipo (O1 ou O2)
df['Tamanho'] = df['Organizacao'].apply(lambda x: int(re.search(r'_S(\d+)', x).group(1)))
df['Tipo'] = df['Organizacao'].str[:2]

# Ordenar pelo tamanho
df = df.sort_values(by='Tamanho')

# Separar O1 e O2
o1 = df[df['Tipo'] == 'O1']
o2 = df[df['Tipo'] == 'O2']

# ==========================================
# GRÁFICO 1: CPI por Tamanho do Traço (O1 vs O2)
# ==========================================
plt.figure(figsize=(10, 5))
plt.plot(o1['Tamanho'], o1['CPI'], marker='o', linestyle='-', color='blue', label='O1 (Monociclo)')
plt.plot(o2['Tamanho'], o2['CPI'], marker='s', linestyle='-', color='red', label='O2 (Pipeline)')
plt.title('CPI em função do tamanho do traço')
plt.xlabel('Tamanho do traço (instruções)')
plt.ylabel('CPI')
plt.xscale('log')
plt.xticks(o1['Tamanho'], o1['Tamanho'])
plt.legend()
plt.grid(True, linestyle='--', alpha=0.7)
plt.tight_layout()
plt.savefig('grafico_cpi.png')
plt.close()

# ==========================================
# GRÁFICO 2: Ciclos Totais (O1 vs O2)
# ==========================================
plt.figure(figsize=(10, 5))
plt.plot(o1['Tamanho'], o1['Ciclos'], marker='o', linestyle='-', color='blue', label='O1 (Monociclo)')
plt.plot(o2['Tamanho'], o2['Ciclos'], marker='s', linestyle='-', color='red', label='O2 (Pipeline)')
plt.title('Número de ciclos de clock em função do tamanho do traço')
plt.xlabel('Tamanho do traço (instruções)')
plt.ylabel('Ciclos')
plt.xscale('log')
plt.xticks(o1['Tamanho'], o1['Tamanho'])
plt.legend()
plt.grid(True, linestyle='--', alpha=0.7)
plt.tight_layout()
plt.savefig('grafico_ciclos.png')
plt.close()

# ==========================================
# GRÁFICO 3: Speedup (Apenas para ilustrar a diferença)
# ==========================================
# Como O1 e O2 têm ciclos parecidos neste projeto, o speedup em ciclos será ~1.
# Vamos colocar uma linha de referência.
speedup = o1['Ciclos'].values / o2['Ciclos'].values

plt.figure(figsize=(8, 5))
plt.bar(o1['Tamanho'].astype(str), speedup, color='green')
plt.axhline(y=1.0, color='black', linestyle='--', linewidth=1, label='Ideal (1.0)')
plt.title('Speedup de O2 sobre O1 (Baseado em Ciclos)')
plt.xlabel('Tamanho do traço (instruções)')
plt.ylabel('Speedup (Ciclos O1 / Ciclos O2)')
plt.ylim(0, 1.2)
plt.legend()
plt.grid(axis='y', linestyle='--', alpha=0.7)
plt.tight_layout()
plt.savefig('grafico_speedup.png')
plt.close()

print("Gráficos gerados com sucesso: grafico_cpi.png, grafico_ciclos.png e grafico_speedup.png")