import numpy as np

from SuperLaserLand_JD_RP import SuperLaserLand_JD_RP

import RP_PLL

# This is a subclass of SuperLaserLand_JD_RP, and we simply override
# the methods that would not work without a physical setup attached.
class SuperLaserLand_mock(SuperLaserLand_JD_RP):


	def __init__(self):
		super(SuperLaserLand_mock, self).__init__()
		self.bIntroduceCommsException = {'setup_write': False, 
		'read_adc_samples_from_DDR2': False, 
		'read_ddc_samples_from_DDR2': False,
		'trigger_write': False,
		'setDitherLockInState': False,
		'set_dac_offset': False}
		self.random_seed = 0

		pass

	def setup_write(self, selector, Num_samples):
		# input validation:
		if not selector in self.LOGGER_MUX.values():
			raise Exception('Invalid selector value')

		self.Num_samples_write = int(Num_samples)  # no such restriction with the Red Pitaya implementation
		self.Num_samples_read = self.Num_samples_write
		self.last_selector = selector

		if self.bIntroduceCommsException['setup_write']:
			raise RP_PLL.CommsError('test exception')

	def read_adc_samples_from_DDR2(self):
		if self.bIntroduceCommsException['read_adc_samples_from_DDR2']:
			raise RP_PLL.CommsError('test exception')


		# need to return a representative test vector (tone + noise maybe?)
		samples_out = 0.1*np.cos(2*np.pi*25e6/self.fs*np.arange(0., self.Num_samples_read))
		# if this is one of the dac, add an offset, different for each dac, so that we can test the reads easily:
		if self.last_selector == self.LOGGER_MUX['DAC0']:
			samples_out = samples_out + 1e-4
		elif self.last_selector == self.LOGGER_MUX['DAC1']:
			samples_out = samples_out + 2e-4
		elif self.last_selector == self.LOGGER_MUX['DAC2']:
			samples_out = samples_out + 3e-4
		# add noise, but keep the same seed everytime for repeatable results:
		np.random.seed(self.random_seed)
		samples_out = samples_out + 1e-3 * np.random.randn(self.Num_samples_read)
		samples_out = np.round(2.**(16-1) * samples_out)
		ref_exp0 = 1. + 0.j
		return (samples_out, ref_exp0)


	def read_ddc_samples_from_DDR2(self):
		if self.bIntroduceCommsException['read_ddc_samples_from_DDR2']:
			raise RP_PLL.CommsError('test exception')


		# need to return a representative test vector (tone + noise maybe?)
		# samples_out = 0.1*np.cos(2*np.pi*1e6/self.fs*np.arange(0., self.Num_samples_read))
		samples_out = np.zeros((self.Num_samples_read, ))
		# make the two test cases different a bit:
		if self.last_selector == self.LOGGER_MUX['DDC0']:
			samples_out = samples_out + 1e5
		elif self.last_selector == self.LOGGER_MUX['DDC1']:
			samples_out = samples_out + 2e5
		# # add noise, but keep the same seed everytime for repeatable results:
		# np.random.seed(self.random_seed)
		# samples_out = samples_out + 1e6 * np.diff(np.random.randn(self.Num_samples_read), prepend=(0,))
		

		return samples_out

	# these don't need to do anything at the level of simulation we are choosing
	def trigger_write(self):
		if self.bIntroduceCommsException['trigger_write']:
			raise RP_PLL.CommsError('test exception')
		pass

	def setDitherLockInState(self, *args, **kwargs):
		if self.bIntroduceCommsException['setDitherLockInState']:
			raise RP_PLL.CommsError('test exception')
		pass

	def wait_for_write(self):
		pass

	def set_dac_offset(self, dac_number, offset):
		if self.bIntroduceCommsException['set_dac_offset']:
			raise RP_PLL.CommsError('test exception')
		pass

	def set_integrator_settings(self, integrator_number, hold, flip_sign, lock, gain_in_bits):
		pass