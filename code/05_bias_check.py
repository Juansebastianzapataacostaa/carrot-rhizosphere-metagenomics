import pandas as pd

files = {
    "CAZy": ("Functional_Analysis_Clean/cazy_clean.tsv"),
    "KEGG": ("Functional_Analysis_Clean/kegg_clean.tsv"),
    "NCyc": ("Functional_Analysis_Clean/ncyc_clean.tsv")
}

def summary(path, name):
    df = pd.read_csv(path, sep="\t")

    print("\n====================")
    print(name)
    print("Total genes:", len(df))
    print("Systems distribution:")
    print(df["system"].value_counts())

for k, v in files.items():
    summary(v, k)
