import pandas as pd
import os

df = pd.read_csv("Functional_Analysis_Clean/cazy_clean.tsv", sep="\t")

# matriz: abundancia por sistema + réplica + función
mat = df.groupby(
    ["system", "replicate", "dbcan_id"]
).size().reset_index(name="count")

os.makedirs("Matrices", exist_ok=True)

mat.to_csv("Matrices/cazy_matrix.tsv", sep="\t", index=False)

print("✔ CAZy matrix done:", mat.shape)
