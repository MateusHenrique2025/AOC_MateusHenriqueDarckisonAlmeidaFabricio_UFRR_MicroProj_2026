import os

def gerar_traco(num_instrucoes):
    instrucoes = []
    
    # Instruções 100% independentes (escrevem em registradores diferentes a cada vez)
    # Usamos "addi" para não depender de leituras anteriores.
    base_instrucoes = [
        "20080005", # addi $t0, $zero, 5
        "20090003", # addi $t1, $zero, 3
        "200A0002", # addi $t2, $zero, 2
        "200B0001", # addi $t3, $zero, 1
        "200C0004", # addi $t4, $zero, 4
    ]
    
    # Preenche com as instruções
    for i in range(num_instrucoes):
        instrucoes.append(base_instrucoes[i % 5])
        
    # Adiciona o break no final
    instrucoes.append("0000000D")
    
    # Escreve o arquivo .hex
    caminho = f"tracos/s_{num_instrucoes}.hex"
    with open(caminho, "w", newline='\n') as f:
        for inst in instrucoes:
            f.write(f"{inst}\n")
            
    print(f"Gerado: {caminho} ({num_instrucoes} instruções + break)")

# Tamanhos exigidos pelo PDF
tamanhos = [5, 10, 20, 50, 100, 200]

print("Gerando arquivos da Série S...")
for t in tamanhos:
    gerar_traco(t)

print("Série S gerada com sucesso na pasta tracos/!")