import pandas as pd
import os

df = pd.read_csv("Functional_Analysis_Clean/ncyc_clean.tsv", sep="\t")

mat = df.groupby(
    ["system", "replicate", "hit_id"]
).size().reset_index(name="count")

os.makedirs("Matrices", exist_ok=True)

mat.to_csv("Matrices/ncyc_matrix.tsv", sep="\t", index=False)

print("✔ NCyc matrix done:", mat.shape)
