/*******************************************************************************
 * Copyright (c) 2000, 2004 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 * 
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/
package org.eclipse.jdt.internal.compiler.ast;

import org.eclipse.jdt.internal.compiler.ASTVisitor;
import org.eclipse.jdt.internal.compiler.impl.*;
import org.eclipse.jdt.internal.compiler.codegen.*;
import org.eclipse.jdt.internal.compiler.flow.*;
import org.eclipse.jdt.internal.compiler.lookup.*;

public class CaseStatement extends Statement {
	
	public Expression constantExpression;
	public CaseLabel targetLabel;
	boolean isEnumConstant;
	
	public CaseStatement(Expression constantExpression, int sourceEnd, int sourceStart) {
		this.constantExpression = constantExpression;
		this.sourceEnd = sourceEnd;
		this.sourceStart = sourceStart;
	}

	public FlowInfo analyseCode(
		BlockScope currentScope,
		FlowContext flowContext,
		FlowInfo flowInfo) {

		if (constantExpression != null) {
			if (!this.isEnumConstant && constantExpression.constant == NotAConstant) {
				currentScope.problemReporter().caseExpressionMustBeConstant(constantExpression);
			}
			this.constantExpression.analyseCode(currentScope, flowContext, flowInfo);
		}
		return flowInfo;
	}

	public StringBuffer printStatement(int tab, StringBuffer output) {

		printIndent(tab, output);
		if (constantExpression == null) {
			output.append("default : "); //$NON-NLS-1$
		} else {
			output.append("case "); //$NON-NLS-1$
			constantExpression.printExpression(0, output).append(" : "); //$NON-NLS-1$
		}
		return output.append(';');
	}
	
	/**
	 * Case code generation
	 *
	 */
	public void generateCode(BlockScope currentScope, CodeStream codeStream) {

		if ((bits & IsReachableMASK) == 0) {
			return;
		}
		int pc = codeStream.position;
		targetLabel.place();
		codeStream.recordPositionsFrom(pc, this.sourceStart);
	}

	/**
	 * No-op : should use resolveCase(...) instead.
	 */
	public void resolve(BlockScope scope) {
		// no-op : should use resolveCase(...) instead.
	}

	/**
	 * Returns the constant intValue or ordinal for enum constants. If constant is NotAConstant, then answers Float.MIN_VALUE
	 * @see org.eclipse.jdt.internal.compiler.ast.Statement#resolveCase(org.eclipse.jdt.internal.compiler.lookup.BlockScope, org.eclipse.jdt.internal.compiler.lookup.TypeBinding, org.eclipse.jdt.internal.compiler.ast.SwitchStatement)
	 */
	public Constant resolveCase(
		BlockScope scope,
		TypeBinding switchExpressionType,
		SwitchStatement switchStatement) {

	    scope.switchCase = this; // record entering in a switch case block
	    
		if (constantExpression == null) {
			// remember the default case into the associated switch statement
			if (switchStatement.defaultCase != null)
				scope.problemReporter().duplicateDefaultCase(this);
	
			// on error the last default will be the selected one ...	
			switchStatement.defaultCase = this;
			return NotAConstant;
		}
		// add into the collection of cases of the associated switch statement
		switchStatement.cases[switchStatement.caseCount++] = this;
		// tag constant name with enum type for privileged access to its members
		if (switchExpressionType.isEnum() && (constantExpression instanceof SingleNameReference)) {
			((SingleNameReference) constantExpression).setActualReceiverType((ReferenceBinding)switchExpressionType);
		}
		TypeBinding caseType = constantExpression.resolveType(scope);
		if (caseType == null || switchExpressionType == null) return NotAConstant;
		if (constantExpression.isConstantValueOfTypeAssignableToType(caseType, switchExpressionType)
				|| caseType.isCompatibleWith(switchExpressionType)) {
			if (caseType.isEnum()) {
				this.isEnumConstant = true;
				if (constantExpression instanceof NameReference
						&& (constantExpression.bits & RestrictiveFlagMASK) == Binding.FIELD) {
					if (constantExpression instanceof QualifiedNameReference) {
						 scope.problemReporter().cannotUseQualifiedEnumConstantInCaseLabel((QualifiedNameReference)constantExpression);
					}
					return Constant.fromValue(((NameReference)constantExpression).fieldBinding().id); // ordinal value
				}
			} else {
				return constantExpression.constant;
			}
		} else if (scope.isBoxingCompatibleWith(switchExpressionType, caseType)) {
			constantExpression.computeConversion(scope, caseType, switchExpressionType);
			return constantExpression.constant;
		}
		scope.problemReporter().typeMismatchError(caseType, switchExpressionType, constantExpression);
		return NotAConstant;
	}


	public void traverse(
		ASTVisitor visitor,
		BlockScope blockScope) {

		if (visitor.visit(this, blockScope)) {
			if (constantExpression != null) constantExpression.traverse(visitor, blockScope);
		}
		visitor.endVisit(this, blockScope);
	}
}
