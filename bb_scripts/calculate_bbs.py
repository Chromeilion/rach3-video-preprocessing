import argparse as ap
from rach3datautils.utils.dataset import DatasetUtils
from ultralytics import YOLO
from tqdm import tqdm
import pickle
import json


def main():
    parser = ap.ArgumentParser()
    parser.add_argument("-d", "--root-dir", required=True)
    parser.add_argument('-m', '--model-location', required=True)
    args = parser.parse_args()

    ds = DatasetUtils(args.root_dir)
    sessions = ds.get_sessions(".mp4")

    model = YOLO(args.model_location)
    box_preds = []
    box_preds_j = []
    for session in tqdm(sessions):
        session_preds = []
        videos = session.video.splits_list
        for video in videos:
            pred = model.predict(source=str(video), stream=True)
            session_preds.append(next(pred))

        filtered_session_preds = [
            i for i in session_preds if i.boxes.conf.shape[0] > 0
        ]
        best_pred = max(filtered_session_preds, key=lambda x: x.boxes.conf[0])
        box_preds.append(best_pred.tojson())
        box_preds_j.append({"box": json.loads(best_pred.tojson()),
                            "session_id": str(session.id)})

    with open("box_preds.pkl", "wb") as f:
        pickle.dump(box_preds, f, -1)

    with open("box_preds.json", "w") as f:
        json.dump(box_preds_j, f)


if __name__ == '__main__':
    main()
