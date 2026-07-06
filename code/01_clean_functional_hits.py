import pandas as pd
import os
import glob

# =========================
# CONFIG
# =========================
SYSTEMS = ["BS", "MCR", "SCR"]
REPLICATES = ["1", "2", "3", "4"]

OUT_DIR = "Functional_Analysis_Clean"

# =========================
# HELPERS
# =========================
def safe_read(path, sep="\t"):
    """Lee archivo solo si existe y no está vacío"""
    if not os.path.exists(path):
        return None
    if os.path.getsize(path) == 0:
        return None
    try:
        return pd.read_csv(path, sep=sep)
    except Exception as e:
        print(f"[WARN] Error leyendo {path}: {e}")
        return None


# =========================
# CAZy CLEAN
# =========================
def load_cazy(ann_path, system, rep):
    file_path = os.path.join(ann_path, "dbcan", "cazy_hits.tsv")
    if not os.path.exists(file_path):
        return None

    df = pd.read_csv(
        file_path,
        sep="\t",
        header=None,
        names=["gene_id", "dbcan_id", "evalue", "score", "col5", "col6"]
    )

    df["system"] = system
    df["replicate"] = rep
    df["db"] = "CAZy"
    return df


# =========================
# KEGG CLEAN (eggNOG)
# =========================
def load_kegg(ann_path, system, rep):
    files = glob.glob(os.path.join(ann_path, "*emapper.annotations"))
    if len(files) == 0:
        return None

    file_path = files[0]

    header = None
    skip = 0

    with open(file_path) as f:
        for i, line in enumerate(f):
            if line.startswith("#query"):
                header = line.strip().replace("#", "").split("\t")
                skip = i + 1
                break

    if header is None:
        return None

    df = pd.read_csv(file_path, sep="\t", skiprows=skip, names=header)
    df["system"] = system
    df["replicate"] = rep
    df["db"] = "KEGG"
    return df


# =========================
# NCYC CLEAN
# =========================
def load_ncyc(ann_path, system, rep):
    file_path = os.path.join(ann_path, "ncyc", "ncyc_hits.tsv")
    if not os.path.exists(file_path):
        return None

    df = pd.read_csv(
        file_path,
        sep="\t",
        header=None,
        names=["gene_id", "hit_id", "identity", "coverage", "score", "evalue", "bitscore"]
    )

    df["system"] = system
    df["replicate"] = rep
    df["db"] = "NCyc"
    return df


# =========================
# MAIN
# =========================
def main():

    if not os.path.exists(OUT_DIR):
        os.makedirs(OUT_DIR)

    cazy_all = []
    kegg_all = []
    ncyc_all = []

    print("🔄 Iniciando limpieza funcional...")

    for sys in SYSTEMS:
        for rep in REPLICATES:

            ann = os.path.join(sys, rep, "annotation")

            if not os.path.exists(ann):
                continue

            print(f" -> Procesando {sys}/{rep}")

            cazy = load_cazy(ann, sys, rep)
            if cazy is not None:
                cazy_all.append(cazy)

            kegg = load_kegg(ann, sys, rep)
            if kegg is not None:
                kegg_all.append(kegg)

            ncyc = load_ncyc(ann, sys, rep)
            if ncyc is not None:
                ncyc_all.append(ncyc)

    print("\n📦 Exportando matrices...")

    # =========================
    # SAFE CONCAT
    # =========================

    if len(cazy_all) > 0:
        pd.concat(cazy_all).to_csv(
            os.path.join(OUT_DIR, "cazy_clean.tsv"),
            sep="\t", index=False
        )
        print("✔ CAZy listo")

    else:
        print("⚠ CAZy vacío")

    if len(kegg_all) > 0:
        pd.concat(kegg_all).to_csv(
            os.path.join(OUT_DIR, "kegg_clean.tsv"),
            sep="\t", index=False
        )
        print("✔ KEGG listo")

    else:
        print("⚠ KEGG vacío")

    if len(ncyc_all) > 0:
        pd.concat(ncyc_all).to_csv(
            os.path.join(OUT_DIR, "ncyc_clean.tsv"),
            sep="\t", index=False
        )
        print("✔ NCyc listo")

    else:
        print("⚠ NCyc vacío")

    print("\n✅ STEP 1 COMPLETADO")


if __name__ == "__main__":
    main()
