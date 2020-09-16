#! /usr/bin/env python

import sys
from os import getenv
from sqlite3 import connect
import fileinput


def main():
    with connect(getenv('DB_URI', './pre-sqlite-olt.db')) as db:
        for line in fileinput.input():
            db.execute(f"INSERT INTO {getenv('TABLE')} VALUES (?)", (line, ))


if __name__ == '__main__':
    main()
