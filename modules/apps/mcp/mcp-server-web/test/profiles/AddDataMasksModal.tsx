/**
 * SPDX-FileCopyrightText: (c) 2026 Liferay, Inc. https://liferay.com
 * SPDX-License-Identifier: LGPL-2.1-or-later OR LicenseRef-Liferay-DXP-EULA-2.0.0-2023-06
 */

import {render, screen} from '@testing-library/react';
import React from 'react';

import '@testing-library/jest-dom';

import AddDataMasksModal from '../../src/main/resources/META-INF/resources/js/profiles/AddDataMasksModal';

import type {
	DataMask,
	DataMaskTypeKey,
} from '../../src/main/resources/META-INF/resources/js/types';

const PROFILE_ERC = 'PROFILE_ERC';

function createDataMask(
	key: DataMaskTypeKey,
	name: string,
	externalReferenceCode: string
): DataMask {
	return {
		detectionRegex: '\\d+',
		externalReferenceCode,
		maskType: {key, name: key === 'system' ? 'System' : 'Custom'},
		name,
		replacementValue: '[X]',
	};
}

const systemAndCustomDataMasks = [
	createDataMask('system', 'Email Address', 'SYSTEM_EMAIL'),
	createDataMask('system', 'Phone Number', 'SYSTEM_PHONE'),
	createDataMask('custom', 'Project Codename', 'CUSTOM_CODENAME'),
];

function renderModal({
	dataMasks = systemAndCustomDataMasks,
	onAdded = jest.fn(),
	onClose = jest.fn(),
} = {}) {
	const {container} = render(
		<AddDataMasksModal
			dataMasks={dataMasks}
			nextExecutionOrder={1}
			onAdded={onAdded}
			onClose={onClose}
			profileExternalReferenceCode={PROFILE_ERC}
		/>
	);

	return {container, onAdded, onClose};
}

describe('AddDataMasksModal', () => {
	it('offers no search and no selection bar when there are no masks', () => {
		renderModal({dataMasks: []});

		expect(
			screen.getByText('no-data-masks-were-found')
		).toBeInTheDocument();
		expect(screen.queryByRole('searchbox', {name: 'search'})).toBeNull();
		expect(screen.queryByText('nothing-selected')).toBeNull();
	});
});
