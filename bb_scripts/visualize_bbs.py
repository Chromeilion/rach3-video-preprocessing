import argparse as ap
import pickle
from PIL import Image
from pathlib import Path


def main():
    parser = ap.ArgumentParser()
    parser.add_argument("-p", "--preds", required=True)
    args = parser.parse_args()

    with open(args.preds, "rb") as f:
        preds = pickle.load(f)

    for pred in preds:
        im_array = pred.plot()
        im = Image.fromarray(im_array[..., ::-1])
        im.save(f"./preds/{Path(pred.path).stem}.jpg")


if __name__ == "__main__":
    main()
