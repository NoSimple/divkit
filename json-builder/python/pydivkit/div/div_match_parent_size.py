# Generated code. Do not modify.
# flake8: noqa: F401, F405, F811

from __future__ import annotations

import enum
import typing

from pydivkit.core import BaseDiv, Field


# Element size adjusts to a parent element.
class DivMatchParentSize(BaseDiv):

    def __init__(
        self, *,
        type: str = "match_parent",
        weight: typing.Optional[float] = None,
    ):
        super().__init__(
            type=type,
            weight=weight,
        )

    type: str = Field(default="match_parent")
    weight: typing.Optional[float] = Field(
        description=(
            "Weight when distributing free space between elements with "
            "the size type`match_parent` inside an element. If the "
            "weight isn\'t specified, the elementswill divide the place "
            "equally."
        ),
    )


DivMatchParentSize.update_forward_refs()
