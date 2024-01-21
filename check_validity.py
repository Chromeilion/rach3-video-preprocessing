import argparse as ap
import os

from rach3datautils.utils.dataset import DatasetUtils
from rach3datautils.utils.session import Session
from rach3datautils.alignment.verification import Verify
from tqdm import tqdm
from multiprocessing import Pool


def verify(s: Session):
    s.sort_audios()
    s.sort_videos()

    for video_split, flac_split, midi_split in zip(
            s.video.splits_list,
            s.flac.splits_list,
            s.midi.splits_list):
        return Verify().run_checks(
            video=video_split,
            flac=flac_split,
            midi=midi_split
        )


def main():
    parser = ap.ArgumentParser()
    parser.add_argument("-pd",
                        "--processed-dataset-root-dir",
                        required=True)
    parser.add_argument("-od",
                        "--original-dataset-root-dir",
                        required=True)
    args = parser.parse_args()

    ds_p = DatasetUtils(args.processed_dataset_root_dir)
    ds_o = DatasetUtils(args.original_dataset_root_dir)
    sessions_p = ds_p.get_sessions()
    sessions_o = ds_o.get_sessions()

    assert len(sessions_p) == len(sessions_o)

    # Make sure both lists have the same sorting
    sessions_p.sort(key=lambda x: x.id.full_id)
    sessions_o.sort(key=lambda x: x.id.full_id)

    for so, sp in zip(sessions_p, sessions_o):
        assert so.id.full_id == sp.id.full_id
        assert all(a.name == b.name for a, b in zip(so.all_files(),
                                                    sp.all_files()))

    p: Pool
    with Pool(processes=os.cpu_count()//2) as p:
        for res in tqdm(p.imap(verify, sessions_p), total=len(sessions_p)):
            assert res

    print("All tests passed!")


if __name__ == '__main__':
    main()
