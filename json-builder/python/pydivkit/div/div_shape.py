# Generated code. Do not modify.
# flake8: noqa: F401, F405, F811

from __future__ import annotations

import enum
import typing
from typing import Union

from pydivkit.core import BaseDiv, Field

from . import div_circle_shape, div_rounded_rectangle_shape


DivShape = Union[
    div_rounded_rectangle_shape.DivRoundedRectangleShape,
    div_circle_shape.DivCircleShape,
]
