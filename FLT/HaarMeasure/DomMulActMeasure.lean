/-
Copyright (c) 2024 Andrew Yang, Yaël Dillies, Javier López-Contreras. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Andrew Yang, Yaël Dillies, Javier López-Contreras
-/
import Mathlib.MeasureTheory.Measure.Haar.Unique

open scoped NNReal Pointwise ENNReal

namespace MeasureTheory.Measure

variable {G A : Type*} [Group G] [AddCommGroup A] [DistribMulAction G A]
  [MeasurableSpace A]
  -- We only need `MeasurableConstSMul G A` but we don't have this class. So we erroneously must
  -- assume `MeasurableSpace G` + `MeasurableSMul G A`
  [MeasurableSpace G] [MeasurableSMul G A]
variable {μ ν : Measure A} {g : G}

lemma domSMul_apply (μ : Measure A) (g : Gᵈᵐᵃ) (s : Set A) :
    (g • μ) s = μ ((DomMulAct.mk.symm g) • s) := by
  refine ((MeasurableEquiv.smul ((DomMulAct.mk.symm g : G)⁻¹)).map_apply _).trans ?_
  congr 1
  exact Set.preimage_smul_inv (DomMulAct.mk.symm g) s

lemma integral_domSMul {α} [NormedAddCommGroup α] [NormedSpace ℝ α] (g : Gᵈᵐᵃ) (f : A → α) :
    ∫ x, f x ∂g • μ = ∫ x, f ((DomMulAct.mk.symm g)⁻¹ • x) ∂μ :=
  integral_map_equiv (MeasurableEquiv.smul ((DomMulAct.mk.symm g : G)⁻¹)) f

variable [TopologicalSpace A] [BorelSpace A] [IsTopologicalAddGroup A] [LocallyCompactSpace A]
  [ContinuousConstSMul G A] [μ.IsAddHaarMeasure] [ν.IsAddHaarMeasure]

instance : SMulCommClass ℝ≥0 Gᵈᵐᵃ (Measure A) where
  smul_comm r g μ := show r • μ.map _ = (r • μ).map _ by simp

instance : SMulCommClass Gᵈᵐᵃ ℝ≥0 (Measure A) := .symm ..

instance (g : Gᵈᵐᵃ) [Regular μ] : Regular (g • μ) :=
  Regular.map (μ := μ) (Homeomorph.smul ((DomMulAct.mk.symm g : G)⁻¹))

instance (g : Gᵈᵐᵃ) : (g • μ).IsAddHaarMeasure :=
  (DistribMulAction.toAddEquiv _ (DomMulAct.mk.symm g⁻¹)).isAddHaarMeasure_map _
    (continuous_const_smul _) (continuous_const_smul _)

variable (μ ν) in
lemma addHaarScalarFactor_domSMul (g : Gᵈᵐᵃ) :
    addHaarScalarFactor (g • μ) (g • ν) = addHaarScalarFactor μ ν := by
  obtain ⟨⟨f, f_cont⟩, f_comp, f_nonneg, f_zero⟩ :
    ∃ f : C(A, ℝ), HasCompactSupport f ∧ 0 ≤ f ∧ f 0 ≠ 0 := exists_continuous_nonneg_pos 0
  have int_f_ne_zero : ∫ x, f x ∂g • ν ≠ 0 :=
    (f_cont.integral_pos_of_hasCompactSupport_nonneg_nonzero f_comp f_nonneg f_zero).ne'
  apply NNReal.coe_injective
  rw [addHaarScalarFactor_eq_integral_div (g • μ) (g • ν) f_cont f_comp int_f_ne_zero,
    integral_domSMul, integral_domSMul]
  refine (addHaarScalarFactor_eq_integral_div _ _ (by fun_prop) ?_ ?_).symm
  · exact f_comp.comp_isClosedEmbedding (Homeomorph.smul _).isClosedEmbedding
  · rw [← integral_domSMul]
    exact (f_cont.integral_pos_of_hasCompactSupport_nonneg_nonzero f_comp f_nonneg f_zero).ne'

variable (μ) in
lemma addHaarScalarFactor_smul_congr (g : Gᵈᵐᵃ) :
    addHaarScalarFactor μ (g • μ) = addHaarScalarFactor ν (g • ν) := by
  rw [addHaarScalarFactor_eq_mul _ (g • ν), addHaarScalarFactor_domSMul,
    mul_comm, ← addHaarScalarFactor_eq_mul]

variable (μ) in
lemma addHaarScalarFactor_smul_congr' (g : Gᵈᵐᵃ) :
    addHaarScalarFactor (g • μ) μ = addHaarScalarFactor (g • ν) ν := by
  rw [addHaarScalarFactor_eq_mul _ (g • ν), addHaarScalarFactor_domSMul,
    mul_comm, ← addHaarScalarFactor_eq_mul]
