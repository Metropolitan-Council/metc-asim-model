# ActivitySim
# See full license in LICENSE.txt.
import logging

import numpy as np

from activitysim.abm.models.util import estimation
from activitysim.abm.models import initialize
from activitysim.core import chunk, config, expressions, inject, pipeline, simulate, tracing

logger = logging.getLogger("activitysim")

@inject.step()
def initialize_persons():

    trace_label = "initialize_persons"

    with chunk.chunk_log(trace_label, base=True):

        chunk.log_rss(f"{trace_label}.inside-yield")

        persons = inject.get_table("persons").to_frame()
        assert not persons._is_view
        chunk.log_df(trace_label, "persons", persons)
        del persons
        chunk.log_df(trace_label, "persons", None)

        model_settings = config.read_model_settings(
            "initialize_persons.yaml", mandatory=True
        )
        initialize.annotate_tables(model_settings, trace_label)

        