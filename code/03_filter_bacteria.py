import pandas as pd
import os

TAX_PATH = "Functional_Analysis_Clean/gene_taxonomy.tsv"

print("Loading:", TAX_PATH)

if not os.path.exists(TAX_PATH):
    raise FileNotFoundError(f"No existe archivo: {TAX_PATH}")

tax = pd.read_csv(TAX_PATH, sep="\t")
