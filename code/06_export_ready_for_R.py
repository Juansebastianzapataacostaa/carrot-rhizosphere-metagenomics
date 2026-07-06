import pandas as pd
import os

os.makedirs("R_ready", exist_ok=True)

def pivot(mat, out, feature_col):
    df = pd.read_csv(mat, sep="\t")

    wide = df.pivot_table(
        index=["system", "replicate"],
        columns=feature_col,
        values="count",
        fill_value=0
    ).reset_index()

    wide.to_csv(out, sep="\t", index=False)

pivot("Matrices/cazy_matrix.tsv", "R_ready/cazy_matrix_R.tsv", "dbcan_id")
pivot("Matrices/kegg_matrix.tsv", "R_ready/kegg_matrix_R.tsv", "KEGG_ko")
pivot("Matrices/ncyc_matrix.tsv", "R_ready/ncyc_matrix_R.tsv", "hit_id")

print("✔ R matrices exported")
