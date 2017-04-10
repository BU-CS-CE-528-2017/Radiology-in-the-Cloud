from unittest import TestCase

from pfioh import pfioh

class TestPfioh(TestCase):
    def test_pfioh_constructor(self):
        myMan = pfioh()
        # didn't crash
        self.assertTrue(True)
