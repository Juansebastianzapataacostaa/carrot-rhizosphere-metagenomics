import pandas as pd
import os

df = pd.read_csv("Functional_Analysis_Clean/kegg_clean.tsv", sep="\t")

# ojo: KEGG funcional puede variar según columna real
mat = df.groupby(
    ["system", "replicate", "KEGG_ko"]
).size().reset_index(name="count")

os.makedirs("Matrices", exist_ok=True)

mat.to_csv("Matrices/kegg_matrix.tsv", sep="\t", index=False)

print("✔ KEGG matrix done:", mat.shape)
