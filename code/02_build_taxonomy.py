import pandas as pd
import glob
import os

print("Building taxonomy from eggNOG...")

# =========================
# FIND FILES ROBUSTO
# =========================
files = []
files += glob.glob("BS/*/annotation/*.emapper.annotations")
files += glob.glob("MCR/*/annotation/*.emapper.annotations")
files += glob.glob("SCR/*/annotation/*.emapper.annotations")

print(f"Archivos encontrados: {len(files)}")

if len(files) == 0:
    raise ValueError("No se encontraron archivos emapper.annotations. Revisa rutas.")

tax_list = []

# =========================
# PARSER ROBUSTO
# =========================
for f in files:

    try:
        # buscar header real
        header = None
        skip = 0

        with open(f) as file:
            for i, line in enumerate(file):
                if line.startswith("#query"):
                    header = line.strip().replace("#", "").split("\t")
                    skip = i + 1
                    break

        if header is None:
            print(f"[WARN] Sin header válido: {f}")
            continue

        df = pd.read_csv(f, sep="\t", skiprows=skip, names=header)

        if "query" not in df.columns:
            print(f"[WARN] Sin columna query: {f}")
            continue

        df = df[["query", "max_annot_lvl"]]
        df = df.rename(columns={"query": "gene_id"})

        tax_list.append(df)

    except Exception as e:
        print(f"[ERROR] {f} -> {e}")

# =========================
# OUTPUT SAFE
# =========================
if len(tax_list) == 0:
    raise ValueError("No se pudo construir taxonomía (tax_list vacío)")

tax = pd.concat(tax_list).drop_duplicates()

os.makedirs("Functional_Analysis_Clean", exist_ok=True)

tax.to_csv("Functional_Analysis_Clean/gene_taxonomy.tsv", sep="\t", index=False)

print("OK taxonomy table created")
