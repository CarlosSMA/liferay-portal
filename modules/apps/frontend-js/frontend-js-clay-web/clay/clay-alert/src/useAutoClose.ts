/**
 * SPDX-FileCopyrightText: (c) 2026 Liferay, Inc. https://liferay.com
 * SPDX-License-Identifier: LGPL-2.1-or-later OR LicenseRef-Liferay-DXP-EULA-2.0.0-2023-06
 */

import {useProvider} from '@clayui/provider';
import {useEffect, useRef} from 'react';

interface IProps {
	autoClose?: boolean | number;
	onClose?: () => void;
}

export function useAutoClose({autoClose, onClose}: IProps) {
	const {persistentAlerts} = useProvider();

	const elapsedRef = useRef(0);
	const expiredRef = useRef(false);
	const pauseRequestedRef = useRef(false);
	const startedAtRef = useRef<number>(0);
	const timerRef = useRef<number | null>(null);

	const pauseTimer = () => {
		if (!timerRef.current) {
			return;
		}

		elapsedRef.current =
			elapsedRef.current + (Date.now() - startedAtRef.current);

		clearTimeout(timerRef.current);

		timerRef.current = null;
	};

	const startTimer = () => {
		if (
			!autoClose ||
			persistentAlerts ||
			expiredRef.current ||
			pauseRequestedRef.current ||
			timerRef.current
		) {
			return;
		}

		const autoCloseDuration = autoClose === true ? 10000 : autoClose;

		startedAtRef.current = Date.now();

		timerRef.current = window.setTimeout(
			() => {
				expiredRef.current = true;
				timerRef.current = null;

				onClose?.();
			},
			Math.max(0, autoCloseDuration - elapsedRef.current)
		);
	};

	useEffect(() => {
		startTimer();

		return pauseTimer;
	}, [persistentAlerts]);

	return {
		pauseAutoCloseTimer: () => {
			pauseRequestedRef.current = true;

			pauseTimer();
		},
		startAutoCloseTimer: () => {
			pauseRequestedRef.current = false;

			startTimer();
		},
	};
}
